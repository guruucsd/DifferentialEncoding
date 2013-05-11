function filout = pruning_collect_data(trnc, tstc)
%
% Questions I want to ask:
% 1. What affects the % difference (ipd_spread and ipd_nn) [nStart, nEnd, Sigma, hpl]
% 2. If we have same sigma, but different connectivity, do we see classification differences?
%
% Best way to go:
% 1. parse data up into different ways, and feed into loop_analyses
% 2. use full data to do pruning analysis
%

% our only static parameters:
smidx  = 3; % lotsa smoothing on power spectra
norm_perf = false;


if ~exist('de_PlotFFTs','file')
    if ~exist('uber_sergent_args','file'), addpath('../sergent_1982'); end;
    uber_sergent_args();
end;

trnm   = [trnc{:}]; clear('trnc');
tstm   = [tstc{:}]; clear('tstc');
mSets  = [trnm.mSets];
ac     = [mSets.ac]; 
ct     = [ac.ct];

% for us, density will be a combo between *actual* sigma, and % pruning.
sigmas   = [mSets.sigma]; sigmas = sigmas(1:2:end);
nc_start = [ct.nConnPerHidden_Start];
nc_end   = [ct.nConnPerHidden_End];
nconn    = [mSets.nConns]; 
clear('ac','ct','mSets');

% $HACK: somehow reduct_factor=1.33 data got corrupted, so eliminate here.
reduct_factor = nc_start./nc_end;
bad_idx = find(reduct_factor == (1+1/3));
good_idx = setdiff(1:numel(trnm),  bad_idx);

trnm     = trnm(good_idx);
tstm     = tstm(good_idx);
sigmas   = sigmas(good_idx);
nc_start = nc_start(good_idx);
nc_end   = nc_end(good_idx);
nconn    = nconn(good_idx);
clear('reduct_factor');

% Now calculate the quantities we want, and alias them
%% Change these equations here
calc_density = @(s,ncs,nce) (s);% (s./sqrt(ncs./nce));
calc_nconn   = @(ncs,nce) (ncs./nce);% (nce);

density = unique(calc_density(sigmas, nc_start, nc_end)); nd=length(density);
nconn   = unique(calc_nconn(nc_start, nc_end));           nc=length(nconn);

% Second measure:nconn

freqs1D= tstm(1).stats.rej.ac.ffts.orig.freqs_1D; nf = length(freqs1D);
nhid   = [trnm(1).mSets.nHidden/trnm(1).mSets.hpl trnm(1).mSets.hpl];


%%=======================
% Collect stats
%========================
for hi=1:2
    
    counts      = zeros(nc,nd); % for averaging
    rejs        = zeros(nc, nd);  % rejections
    ipd_spread  = zeros(nc, nd);  % ipd
    ipd_nearest = zeros(nc, nd);  % ipd
    perf        = cell(nc, nd);     
    pow1D_trn   = zeros(nc, nd, nf);
    pow1D_tst   = zeros(nc, nd, nf);
    

    pow1D_o   = reshape(tstm(1).stats.rej.ac.ffts.orig.power1D{1}(smidx,:,:), [1 nf]);
    
    for mi=1:numel(tstm)
        c_ncstart = trnm(mi).mSets.ac.ct.nConnPerHidden_Start; c_ncend = trnm(mi).mSets.ac.ct.nConnPerHidden_End;
        ci = find(nconn == calc_nconn(c_ncstart, c_ncend));
        di = find(density == calc_density(trnm(mi).mSets.sigma(1), c_ncstart, c_ncend));
        counts(ci,di) = counts(ci,di)+1

        if ~isempty(tstm(mi).stats.raw)
%            raw = [tst_stats.raw]; r=[raw.r];
            rejs(ci,di) = rejs(ci,di) + nnz(sum(tstm(mi).stats.raw.r{hi},2));
        elseif ~isempty(trnm(mi).stats.raw)
            rejs(ci,di) = rejs(ci,di) + nnz(sum(trnm(mi).stats.raw.r{hi},2));
        else
            rejs(ci,di) = rejs(ci,di) + 0;
        end;
        if rejs(ci,di)>=trnm(mi).mSets.runs, continue; end;

        pow1D_trn(ci,di,:) = pow1D_trn(ci,di,:) + mean(trnm(mi).stats.rej.ac.ffts.model.power1D{hi}(smidx,:,:),2);
        pow1D_tst(ci,di,:) = pow1D_tst(ci,di,:) + mean(tstm(mi).stats.rej.ac.ffts.model.power1D{hi}(smidx,:,:),2);
         
        ipd_spread(ci,di)  = ipd_spread(ci,di)  + tstm(mi).stats.rej.ac.ipd.from_center_mean(hi);
        ipd_nearest(ci,di) = ipd_nearest(ci,di) + tstm(mi).stats.rej.ac.ipd.nearest_neighbor_mean(hi);
        
        
        if isfield(tstm(mi).stats.rej.basics, 'bars') %sergent
            if isempty(perf{ci,di}), perf{ci,di} = zeros(1,2); end;
            bars = tstm(mi).stats.rej.basics.bars(3:4,hi*(rejs(ci,di)<trnm(mi).mSets.runs))';
            if norm_perf% normalize bars
                perf{ci,di} = perf{ci,di} + bars./sum(bars); 
            else
                perf{ci,di} = perf{ci,di} + bars;
            end; 
        elseif isfield(tstm(mi).stats.rej.basics,'perf') %face recog
            if isempty(perf{ci,di}), perf{ci,di} = zeros(1,1); end;
            perf{ci,di} = perf{ci,di} + mean(tstm(mi).stats.rej.basics.perf.test{hi}{1}(:));
        end;
    end;
    
    % fill in blanks with nan
    for ii=1:numel(perf), if isempty(perf{hi}), perf{ii} = nan(size(perf{1})); end; end;
    
    % Perform averaging
    rejs        = rejs ./ counts;%zeros(nc, nd);  % rejections
    ipd_spread  = ipd_spread ./ counts; %zeros(nc, nd);  % ipd
    ipd_nearest = ipd_nearest ./ counts; zeros(nc, nd);  % ipd
    for ci=1:nc, for di=1:nd, perf{ci,di} = perf{ci,di}./counts(ci,di); end; end;
    pow1D_trn   = pow1D_trn ./ repmat(counts, [1 1 nf]);%nan(nc, nd, nf);
    pow1D_tst   = pow1D_tst ./ repmat(counts, [1 1 nf]);%zeros(nc, nd, nf);
    
    
    %%=======================
    % Collect MORE stats!
    %========================
    
    ipdd_spread = nan(nc,nd,nc,nd);
    ipdd_nearest = nan(nc,nd,nc,nd);
    
    for ci=1:nc
        for di=1:nd
            
            for ci2=1:nc
                for di2=1:nd
                    
    
                     % ipd
                    ipdd_spread(ci,di,ci2,di2)  = ipd_spread(ci,di)- ipd_spread(ci2,di2);
                    ipdd_nearest(ci,di,ci2,di2) = ipd_nearest(ci2,di2)-ipd_nearest(ci,di);
                end;
            end;
        end;
    end;
    
        
    % Clean up workspace
    %clear('mSets','trnm','tstm');
    %clear('ci','ci2','di','di2','mi');
    
    % A little trickery: alias density as sigmas
    sigmas = density;
    ns = nd;
    
    % Now save off the workspace
    filout{hi} = [tempname() '.mat'];
    save(filout{hi}, 'freqs1D', 'ipd_nearest','ipd_spread','ipdd_nearest','ipdd_spread','nc','ns','nf','nconn','sigmas','nhid','perf','pow1D_o','pow1D_trn','pow1D_tst','rejs','smidx');
end;

