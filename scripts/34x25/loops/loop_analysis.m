function loop_analysis(trn, tst, plt, dbg)

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

%%=======================
% Collect stats
%========================
rejs        = nan(nc, ns);  % rejections
ipd_spread  = nan(nc, ns);  % ipd
ipd_nearest = nan(nc, ns);  % ipd
perf        = cell(nc, ns);
pow1D_trn   = nan(nc, ns, nf);
pow1D_tst   = nan(nc, ns, nf);

pow1D_o   = reshape(tst(1).stats.rej.ac.ffts.orig.power1D{1}(smidx,:,:), [1 nf]);
for ci=1:nc
    for si=1:ns
        if ~isempty(tst(ci).stats.raw)
            rejs(ci,si) = nnz(sum(tst(ci).stats.raw.r{si},2));
        elseif ~isempty(trn(ci).stats.raw)
            rejs(ci,si) = nnz(sum(trn(ci).stats.raw.r{si},2));
        else
            rejs(ci,si) = 0;
        end;
        if rejs(ci,si)>=mSets(1).runs, continue; end;

        pow1D_trn(ci,si,:) = mean(trn(ci).stats.rej.ac.ffts.model.power1D{si}(smidx,:,:),2);
        pow1D_tst(ci,si,:) = mean(tst(ci).stats.rej.ac.ffts.model.power1D{si}(smidx,:,:),2);
         
        ipd_spread(ci,si) = tst(ci).stats.rej.ac.ipd.from_center_mean(si);
        ipd_nearest(ci,si) = tst(ci).stats.rej.ac.ipd.nearest_neighbor_mean(si);
        
        if isfield(tst(ci).stats.rej.basics, 'bars')
            perf{ci,si} = tst(ci).stats.rej.basics.bars(3:4,sum(rejs(ci,:)<mSets(1).runs))';
            perf{ci,si} = perf{ci,si}./sum(perf{ci,si}); % normalize bars
        elseif isfield(tst(ci).stats.rej.basics,'perf')
            perf{ci,si} = mean(tst(ci).stats.rej.basics.perf.test{si}{1}(:));
        end;
    end;
end;


%%=======================
% Collect MORE stats!
%========================

ipdd_spread = nan(nc,ns,nc,ns);
ipdd_nearest = nan(nc,ns,nc,ns);

for ci=1:nc
    for si=1:ns
        
        for ci2=1:nc
            for si2=1:ns
                

                 % ipd
                ipdd_spread(ci,si,ci2,si2)  = ipd_spread(ci,si)- ipd_spread(ci2,si2);
                ipdd_nearest(ci,si,ci2,si2) = ipd_nearest(ci2,si2)-ipd_nearest(ci,si);
            end;
        end;
    end;
end;

         
%%========================
% Analyze behavioral 'interaction' between 'hemispheres'
%=========================

% Sergent task
if isfield(tst(1).stats.rej.basics,'bars')
    bars = permute(reshape(cell2mat(perf)', [2 size(perf)]), [3 2 1]);
    bars_diff = diff(bars,[],3);
    
else
    bars_diff = cell2mat(perf);
end;

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
    legend(guru_csprintf('\\sigma=%.1fpx', num2cell(sigmas)), 'Location', 'best' )
    xlabel('nconn'); set(gca, 'xtick', nconn);
    ylabel('rt(L-S+) - rt(L+S-)');
    title('Relationship between behavioral asymmetry, nconn, and sigma');
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

bardd = nan(nc,ns,nc,ns);
for ci=1:nc
    for si=1:ns
        for ci2=1:nc
            for si2=1:ns
                % difference in the difference of bars
                bardd(ci,si,ci2,si2) = bars_diff(ci,si)-bars_diff(ci2,si2);
            end;
        end;
    end;
end;    

% Plot bar difference-difference vs spread difference
if ismember('bardd_ipd_spread',plt) || ismember('all',plt)
    de_NewFig('bardd_ipd_spread');

    [x,idx] = sort(ipdd_spread(:));
    y = bardd(idx);

    plot(x(x~=0), y(x~=0), '.', 'LineWidth', 2.0);

    xlabel('difference in distance to spread');
    ylabel('bar difference difference ;)');
    title('Relationship between spread and behavioral asymmetry');
end;

% Plot bar difference-difference vs density difference
if ismember('bardd_ipd_nearest',plt) || ismember('all',plt)
    de_NewFig('bardd_ipd_nearest');

    [x,idx] = sort(ipdd_nearest(:));
    y = bardd(idx);

    plot(x(x~=0), y(x~=0), '.', 'LineWidth', 2.0);

    xlabel('difference in distance to nearest neighbor');
    ylabel('bar difference difference ;)');
    title('Relationship between density and behavioral asymmetry');
end;



%%========================
% Analyze ipd
%=========================

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
    
    mfe_suptitle('Difference in spatial spread');
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
    mfe_suptitle('Difference in density (nearest neighbor distance)');
end;



%%========================
% Analyze frequency crossover
%=========================

       
for ii=1:2
    if ii==1, lbl='trn'; pow1D=pow1D_trn;
    else,     lbl='tst'; pow1D=pow1D_tst;
    end;
    
    dims = 10;

    xover_freq = nan(nc,ns,nc,ns);
    pdiff = pow1D - repmat(reshape(pow1D_o, [1 1 nf]), [nc ns 1]);
    pddiff_all = nan(nf,nc,ns,nc,ns);
    coeffs_all = nan(dims+1,nc,ns,nc,ns);

    for ci=1:nc
        for si=1:ns

            for ci2=1:nc
                for si2=1:ns

                    % Modeling the fft crossing point
                    pddiff = reshape(pdiff(ci,si,:) - pdiff(ci2,si2,:),[1 nf]);
                    pddiff_all(:,ci,si,ci2,si2) = pddiff;
                    
                    % fit a polynomial; add padding to get rid of edge
                    % wiggles, which are not stable
                    f1D = [(freqs1D(1)+[-1:0.01:-0.01]) freqs1D (freqs1D(end)+[0.01:0.01:1])];
                    pdd = [(pddiff(1)*ones(1,100))      pddiff  (pddiff(end)*ones(1,100))];
                    
                    coeffs = polyfit(f1D,pdd,dims);
                    coeffs_all(:,ci,si,ci2,si2) = coeffs;
                    
                    % Find the roots of the polynomial.  Keep only the
                    % best!
                    r = roots(coeffs);
                    r = sort(r(~imag(r)));
                    r = r(freqs1D(1)<=r & r<=freqs1D(end));
                    
                    % Now... which root to choose?? 
                    
                    % Slice up into bands
                    ridx = zeros(size(r));
                    for ri=1:length(r)
                        zro = find(freqs1D>=r(ri),1,'first');
                        % now find on actual curve, backwards and forwards
                        cb = -find(sign(pddiff(max(1,zro+[-1:-1:-50]))) ~= sign(pddiff(zro)), 1, 'first');
                        cf =  find(sign(pddiff(min(end,zro+[ 1:50])))     ~= sign(pddiff(zro)), 1, 'first');
                        if isempty([cb,cf])
                            ridx(ri) = zro;
                        else
                            if isempty(cf), delta=cb;
                            elseif isempty(cb), delta=cf;
                            elseif abs(cb)<abs(cf), delta=cb; 
                            else, delta=cf; end;
                            ridx(ri) = zro+delta; 
                            ridx(ri) = max(1,ridx(ri));
                            ridx(ri) = min(nf,ridx(ri));

                        end;
                    end;
                    
                    if isempty(r)
                        xover_freq(ci,si,ci2,si2) = nan;%sign(sg)*freqs1D(end);
                    else
                        dpddiff = sign(diff(pddiff));
                        ddpddiff = diff(dpddiff);
                        pkidx = find(ddpddiff)+2;
                        %if length(pkidx)>2, pkidx = pkidx(pkidx>=25); end;
                        
                        if ~isempty(pkidx) && pkidx(1)<(nf/3) && any(ridx>=pkidx(1))
                            goodidx = find(ridx>=pkidx(1),1,'first');
                        else
                            goodidx = 1;
                        end;


                        if exist('dbg','var')
                            clf(gcf); hold on;
                            plot(freqs1D, pddiff);
                            plot(freqs1D(ridx(goodidx)), pddiff(ridx(goodidx)), 'r*');
                            title(sprintf('Crossed at %.1f',r(goodidx)));
                            guru_assert(length(goodidx)==1);
                            %guru_assert(abs(sg)>=4);
                            %pause(1.5);
                        end;
                        
                        % determine the sign
                        prev_pk = find(pkidx<ridx(goodidx),1,'last');
                        %next_pk = find(ridx(goodidx)<=pkidx,1,'first');
                        if (isempty(prev_pk))
                            sg = sign(pddiff(1));
                        else
                            sg = sign(-dpddiff(ridx(goodidx)-1));
                        end;
                        ar = trapz(pddiff);
                        sg2 = sum(sign(pddiff));
                        
                        if (sg==-1 && ipdd_nearest(ci,si,ci2,si2)>0)
                            if abs(ar)>50 && abs(sg2)>9*nf/10 && sign(sg2)==sign(sg)
                                sg = sg;
                            elseif abs(sg2)>nf/2 && sign(sg2)==sign(sg)
                                sg = -sg;
                            end;
                            %keyboard;
                        end;
                       % elseif sign(ar) ~= sign(sg2) || sign(ar) ~= sign(sg)
                       %     keyboard
                        xover_freq(ci,si,ci2,si2) = sg*r(goodidx);
                    end;
                end;
            end;
        end;
    end;

    modelfn = @(d,m)(sum(repmat(m(:)',[length(d) 1]).*(repmat(d(:),[1 length(m)]).^repmat(length(m)-1:-1:0,[length(d) 1])),2));

    
    % Plot all that didn't have real crossing points, see if they look reasonable.
    if ismember('mystery_nan',plt) || (exist('dbg','var') && ismember('all',plt))
        failed_idx = find(abs(xover_freq)==freqs1D(end), 20);
        mystery_nan = failed_idx;%failed_idx(pddiff_all(1,failed_idx)>0 & ~all(pddiff_all(:,failed_idx)>0));
        
        de_NewFig('mystery_nan');
        [nrows, ncols] = guru_optSubplots(length(mystery_nan));
        for mi=1:length(mystery_nan)
            subplot(nrows, ncols, mi); hold on;
            plot(freqs1D, pddiff_all(:,mystery_nan(mi)), 'linewidth', 2.0);
            plot(freqs1D, modelfn(freqs1D, squeeze(coeffs_all(:,mystery_nan(mi)))), 'r')
            axis tight;
        end;
        mfe_suptitle(sprintf('Failures to find a root (%s)', lbl));
    end;


    % Plot all that had unusual crossing points, see if they look reasonable
    if ismember('mystery_ge13',plt) || (exist('dbg','var') && ismember('all',plt))
        mystery_ge13 = find(abs(xover_freq)>=13 & abs(xover_freq)<freqs1D(end), 20);

        de_NewFig('mystery_ge13');
        [nrows, ncols] = guru_optSubplots(length(mystery_ge13));
        for mi=1:length(mystery_ge13)
            coeffs = squeeze(coeffs_all(:,mystery_ge13(mi)));
            pddiff = pddiff_all(:,mystery_ge13(mi));
            
            subplot(nrows, ncols, mi); hold on;
            plot(freqs1D, pddiff, 'linewidth', 2.0);
            plot(freqs1D, modelfn(freqs1D, coeffs), 'r')
            plot(abs(xover_freq(mystery_ge13(mi))), lin_interp(freqs1D, pddiff, abs(xover_freq(mystery_ge13(mi)))), '*k');
            axis tight;
        end;
        mfe_suptitle(sprintf('Found very protracted roots (>=%.1f) (%s)', min(abs(xover_freq(mystery_ge13))), lbl));
    end;

    
    if ismember('mystery_opposite',plt) || (exist('dbg','var') && ismember('all',plt))
        mystery_opposite = find(ipdd_nearest>0 & xover_freq<0,20);
        
        de_NewFig('mystery_opposite');
        [nrows, ncols] = guru_optSubplots(length(mystery_opposite));
        for mi=1:length(mystery_opposite)
            coeffs = squeeze(coeffs_all(:,mystery_opposite(mi)));
            pddiff = pddiff_all(:,mystery_opposite(mi));
            
            subplot(nrows, ncols, mi); hold on;
            plot(freqs1D, pddiff, 'linewidth', 2.0);
            plot(freqs1D, modelfn(freqs1D, coeffs), 'r')
            plot(abs(xover_freq(mystery_opposite(mi))), lin_interp(freqs1D, pddiff, abs(xover_freq(mystery_opposite(mi)))), '*k');
            axis tight;
        end;
        mfe_suptitle(sprintf('Spacing difference suggests + diff, - diff found (%s)',lbl));
    end;
        
    
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
        mfe_suptitle(sprintf('Crossing point (%s)', lbl));
    end;

    % Spread from center vs frequency cross-over
    if ismember('xover_ipd_spread',plt) || ismember('all',plt)
        de_NewFig('xover_ipd_spread');

        [x,idx] = sort(ipdd_spread(:));
        y = xover_freq(:); y = y(idx);

        plot(x(x~=0), y(x~=0), '.', 'LineWidth', 2.0);
        hold on;
        plot(x(isnan(y)), zeros(size(x(isnan(y)))), 'rx')

        xlabel('difference in distance from center');
        ylabel('cross-over freq');
        title(sprintf('Relationship between distance from center and freq asymmetry (%s)',lbl));
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
        title(sprintf('Relationship between density and freq asymmetry (%s)',lbl));
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
        title(sprintf('Relationship between spread and freq asymmetry (%s)',lbl));
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
        title(sprintf('Relationship between density and freq asymmetry (%s)',lbl));
    end;
end;



if exist('dbg','var')
  keyboard;
end;



function yv = lin_interp(x,y,xv)
    idx1 = find(x<=xv,1,'last');
    idx2 = find(x>xv,1,'first');
    x1 = x(idx1);
    x2 = x(idx2);
    y1 = y(idx1);
    y2 = y(idx2);
    
    yv = y1 + (xv-x1)*(y2-y1)/(x2-x1);
    
