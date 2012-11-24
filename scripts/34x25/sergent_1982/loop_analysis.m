function loop_analysis(trn, tst, plt)

if (~exist('plt','var')), plt = {'all'}; end;

% First, find out about training
if iscell(trn), trn = [trn{:}]; tst=[tst{:}]; mSets=[tst.mSets]; end;

% Collect basic inputs
sigmas = mSets(1).sigma;   ns = length(sigmas);
nconn  = [mSets.nConns];   nc = length(nconn);
freqs1D= tst(1).stats.rej.ac.ffts.orig.freqs_1D; nf = length(freqs1D);
nhid   = [mSets(1).nHidden/mSets(1).hpl mSets(1).hpl];
smidx  = 3; % no smoothing

% bleah
[nconn,idx] = unique(nconn); nc = length(nconn);
trn = trn(idx);
tst = tst(idx);

% Collect stats
rejs        = nan(nc, ns);  % rejections
ipd_spread  = nan(nc, ns);  % ipd
ipd_nearest = nan(nc, ns);  % ipd
bars        = nan(nc, ns, 2);
pow1D       = nan(nc, ns, nf);

pow1D_o   = reshape(tst(1).stats.rej.ac.ffts.orig.power1D{1}(smidx,:,:), [1 nf]);
for ci=1:nc
    for si=1:ns
         rejs(ci,si) = nnz(sum(tst(ci).stats.raw.r{si},2));
         pow1D_trn(ci,si,:) = mean(trn(ci).stats.rej.ac.ffts.model.power1D{si}(smidx,:,:),2);
         pow1D_tst(ci,si,:) = mean(tst(ci).stats.rej.ac.ffts.model.power1D{si}(smidx,:,:),2);
    end;

    good_idx = rejs(ci,:)<mSets(1).runs;
    bars(ci,good_idx,:) = tst(ci).stats.rej.basics.bars(3:4,:)';
    ipd_spread(ci,good_idx) = tst(ci).stats.rej.ac.ipd.from_center_mean;
    ipd_nearest(ci,good_idx) = tst(ci).stats.rej.ac.ipd.nearest_neighbor_mean;
end;

% normalize bars?
bars = bars./repmat(sum(bars,3),[1 1 2]);
bars_diff = diff(bars,[],3);


%%========================
% Analyze 'interaction' between 'hemispheres'
%=========================

% Image representing interaction
if ismember('bars_img',plt) || ismember('all',plt)
    de_NewFig('bars_img');
    imagesc(bars_diff); colorbar;
    xlabel('sigmas'); set(gca, 'xtick', 1:ns, 'xticklabel', sigmas);
    ylabel('nconn'); set(gca, 'ytick', 1:nc, 'yticklabel', nconn);
    title('rt(L-S+) - rt(L+S-)');
end;

% Line plot representing interaction
if ismember('bars_lines',plt) || ismember('all',plt)
    de_NewFig('bars_lines');
    plot(nconn, bars_diff, '.-', 'LineWidth', 2.0);
    legend(guru_csprintf('%d', num2cell(sigmas)), 'Location', 'best' )
    xlabel('nconn'); set(gca, 'xtick', nconn);
    ylabel('rt(L-S+) - rt(L+S-)');
    title('');
end;

% Line plot representing interaction; bars vs spread
if ismember('bars_vs_spread',plt) || ismember('all',plt)
    de_NewFig('bars_vs_spread');
    [x,idx] = sort(ipd_spread(:));
    y = bars_diff(idx);
    
    plot(x, y, '.-', 'LineWidth', 2.0);
    xlabel('average distance from center');
    ylabel('difference in error; (L-S+) - (L+S-)');
    title('Relationship between spread from center and classification asymmetry');
end;


% Line plot representing interaction; bars vs nearest neighbor
if ismember('bars_vs_nearest',plt) || ismember('all',plt)
    de_NewFig('bars_vs_nearest');
    [x,idx] = sort(ipd_nearest(:));
    y = bars_diff(idx);
    
    plot(x, y, '.-', 'LineWidth', 2.0);
    xlabel('average distance to nearest neighbor');
    ylabel('difference in error; (L-S+) - (L+S-)');
    title('Relationship between density and classification asymmetry');
end;


%%========================
% Analyze frequency crossover
%=========================

dims = 7;

xover_freq = nan(nc,ns,nc,ns);
pdiff = pow1D - repmat(reshape(pow1D_o, [1 1 nf]), [nc ns 1]);
ipdd_spread = nan(nc,ns,nc,ns);
ipdd_nearest = nan(nc,ns,nc,ns);
bardd = nan(nc,ns,nc,ns);
pddiff_all = nan(nf,nc,ns,nc,ns);
coeffs_all = nan(dims+1,nc,ns,nc,ns);

for ci=1:nc
    for si=1:ns
        
        for ci2=1:nc
            for si2=1:ns

                % Modeling the fft crossing point
                pddiff = reshape(pdiff(ci,si,:) - pdiff(ci2,si2,:),[1 nf]);
                pddiff_all(:,ci,si,ci2,si2) = pddiff;
                [mm(1), mmidx(1)] = min(pddiff);
                [mm(2), mmidx(2)] = max(pddiff);
                
                if (mm(1)<0 && mm(2)>0)
                    if (pddiff(round(end/2))<0), idx = mmidx(2); else, idx=mmidx(1); end;
                    
                    coeffs = polyfit(freqs1D,pddiff,dims);
                    coeffs_all(:,ci,si,ci2,si2) = coeffs;
                    r = roots(coeffs)
                    r = sort(r(~imag(r)));
                    r = r(freqs1D(max(idx-10,1))<=r & r<=freqs1D(end));
                    if ~isempty(r)
                        xover_freq(ci,si,ci2,si2) = r(1);
                    end;
                end;
                
                % difference in the difference of bars
                bardd(ci,si,ci2,si2) = bars_diff(ci,si)-bars_diff(ci2,si2);
                
                % ipd
                ipdd_spread(ci,si,ci2,si2)  = ipd_spread(ci,si)  - ipd_spread(ci2,si2);
                ipdd_nearest(ci,si,ci2,si2) = ipd_nearest(ci,si) - ipd_nearest(ci2,si2);
            end;
        end;
    end;
end;


% Plot all that didn't have real crossing points, see if they look reasonable.
if ismember('mystery_nan',plt) || ismember('all',plt)
    modelfn = @(d,m)(sum(repmat(m(:)',[length(d) 1]).*(repmat(d(:),[1 length(m)]).^repmat(length(m)-1:-1:0,[length(d) 1])),2));
    failed_idx = find(isnan(xover_freq));
    mystery_nan = failed_idx(pddiff_all(1,failed_idx)>0 & ~all(pddiff_all(:,failed_idx)>0));
    [nrows, ncols] = guru_optSubplots(length(mystery_nan));
    de_NewFig('mystery_nan');
    for mi=1:length(mystery_nan)
        subplot(nrows, ncols, mi); hold on;
        plot(freqs1D, pddiff_all(:,mystery_nan(mi)), 'linewidth', 2.0);
        plot(freqs1D, modelfn(freqs1D, squeeze(coeffs_all(:,mystery_nan(mi)))), 'r')
        axis tight;
    end;
end;


% Plot all that had unusual crossing points, see if they look reasonable
if ismember('mystery_ge13',plt) || ismember('all',plt)
    modelfn = @(d,m)(sum(repmat(m(:)',[length(d) 1]).*(repmat(d(:),[1 length(m)]).^repmat(length(m)-1:-1:0,[length(d) 1])),2));
    mystery_ge13 = find(xover_freq>=13);
    [nrows, ncols] = guru_optSubplots(length(mystery_ge13));
    de_NewFig('mystery_ge13');
    for mi=1:length(mystery_ge13)
        subplot(nrows, ncols, mi); hold on;
        plot(freqs1D, pddiff_all(:,mystery_ge13(mi)), 'linewidth', 2.0);
        plot(freqs1D, modelfn(freqs1D, squeeze(coeffs_all(:,mystery_ge13(mi)))), 'r')
        axis tight;
    end;
end;

%% More normalization
xover_freq(xover_freq(:)>=13)=NaN;

% Plot an image of the crossing point
if ismember('xover_img',plt) || ismember('all',plt)
    de_NewFig('xover_img');
    for ci=1:nc
        for si=1:ns
            subplot(nc, ns, si+(ci-1)*ns)
            imagesc(squeeze(xover_freq(ci,si,:,:)), freqs1D([1 end]));
            set(gca, 'xtick', [], 'ytick', []);
            hold on; plot(si,ci,'r*');
            if (si==1), ylabel(sprintf('conn=%d',nconn(ci))); end;
            if (ci==nc),xlabel(sprintf('sig=%.1f',sigmas(si))); end;
        end;
    end;
end;

% Spread from center vs frequency cross-over
if ismember('xover_ipd_spread',plt) || ismember('all',plt)
    de_NewFig('xover_ipd_spread');
    
    [x,idx] = sort(ipdd_spread(:));
    y = xover_freq(:); y = y(idx);
    
    plot(x(find(x)), y(find(x)), '.', 'LineWidth', 2.0);
    hold on;
    plot(x(isnan(y)), 0, 'rx')

    xlabel('difference in distance from center');
    ylabel('cross-over freq');
    title('Relationship between distance from center and freq asymmetry');
end;

% Distance to nearest neighbor vs frequency cross-over point
if ismember('xover_ipd_nearest',plt) || ismember('all',plt)
    de_NewFig('xover_ipd_nearest');
    
    [x,idx] = sort(ipdd_nearest(:));
    y = xover_freq(:); y = y(idx);
    
    plot(x(find(x)), y(find(x)), '.', 'LineWidth', 2.0);
    hold on;
    plot(x(isnan(y)), 0, 'rx')

    xlabel('difference in distance to nearest neighbor');
    ylabel('cross-over freq');
    title('Relationship between density and freq asymmetry');
end;


% Distance to nearest neighbor vs frequency cross-over point
if false && (ismember('freq_ipd_spread',plt) || ismember('all',plt))
    de_NewFig('freq_ipd_spread');
    
    p2 = permute(pow1D,[3 1 2]);
    [x,idx] = sort(ipdd_spread(:));
    [ci,si,ci2,si2] = ind2sub(size(ipdd_spread), idx);
    yz = p2(:,sub2ind([nc ns],ci,si)) - p2(:,sub2ind([nc ns],ci2,si2));
    
    surf(x, freqs1D, yz, 'EdgeColor', 'none');
    hold on; 
    xlabel('difference in distance to spread neighbor');
    ylabel('cross-over freq');
    title('Relationship between spread and freq asymmetry');
end;

% Distance to nearest neighbor vs frequency cross-over point
if false && (ismember('freq_ipd_nearest',plt) || ismember('all',plt))
    de_NewFig('freq_ipd_nearest');
    
    p2 = permute(pow1D,[3 1 2]);
    [x,idx] = sort(ipdd_nearest(:));
    [ci,si,ci2,si2] = ind2sub(size(ipdd_nearest), idx);
    yz = p2(:,sub2ind([nc ns],ci,si)) - p2(:,sub2ind([nc ns],ci2,si2));
    
    surf(x, freqs1D, yz, 'EdgeColor', 'none');
    hold on; 
    
    xlabel('difference in distance to nearest neighbor');
    ylabel('cross-over freq');
    title('Relationship between density and freq asymmetry');
end;



% Plot an image of the spread difference
if ismember('spread_diff_img',plt) || ismember('all',plt)
    de_NewFig('spread_diff_img');
    for ci=1:nc
        for si=1:ns
            subplot(nc, ns, si+(ci-1)*ns)
            imagesc(squeeze(ipdd_spread(ci,si,:,:)), max(abs(ipdd_spread(:)))*[-1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            hold on; plot(si,ci,'r*');
            if (si==1), ylabel(sprintf('conn=%d',nconn(ci))); end;
            if (ci==nc),xlabel(sprintf('sig=%.1f',sigmas(si))); end;
        end;
    end;
end;

% Plot an image of the spread difference
if ismember('nearest_diff_img',plt) || ismember('all',plt)
    de_NewFig('nearest_diff_img');
    for ci=1:nc
        for si=1:ns
            subplot(nc, ns, si+(ci-1)*ns)
            imagesc(squeeze(ipdd_nearest(ci,si,:,:)), max(abs(ipdd_spread(:)))*[-1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            hold on; plot(si,ci,'r*');
            if (si==1), ylabel(sprintf('conn=%d',nconn(ci))); end;
            if (ci==nc),xlabel(sprintf('sig=%.1f',sigmas(si))); end;
        end;
    end;
end;



% Plot bar difference-difference vs spread difference
if ismember('bardd_ipd_spread',plt) || ismember('all',plt)
    de_NewFig('bardd_ipd_spread');
    
    [x,idx] = sort(ipdd_spread(:));
    y = bardd(idx);
    
    plot(x(find(x)), y(find(x)), '.', 'LineWidth', 2.0);

    xlabel('difference in distance to spread');
    ylabel('bar difference difference ;)');
    title('Relationship between spread and behavioral asymmetry');
end;

% Plot bar difference-difference vs density difference
if ismember('bardd_ipd_nearest',plt) || ismember('all',plt)
    de_NewFig('bardd_ipd_nearest');
    
    [x,idx] = sort(ipdd_nearest(:));
    y = bardd(idx);
    
    plot(x(find(x)), y(find(x)), '.', 'LineWidth', 2.0);

    xlabel('difference in distance to nearest neighbor');
    ylabel('bar difference difference ;)');
    title('Relationship between density and behavioral asymmetry');
end;

if exist('dbg','var')
  keyboard;
end;
