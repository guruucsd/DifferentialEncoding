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

if ~exist('de_PlotFFTs','file')
    if ~exist('uber_sergent_args','file'), addpath('../sergent_1982'); end;
    uber_sergent_args();
end;

trnm   = reshape([trnc{:}], size(trnc)); clear('trnc');
tstm   = reshape([tstc{:}], size(tstc)); clear('tstc');
mSets = reshape([trnm.mSets], size(trnm));

% for us, density will be a combo between *actual* sigma, and % pruning.
sigmas = [mSets.sigma]; sigmas = sigmas(1:2:end);
ac = [mSets.ac]; ct = [ac.ct];
nc_start = [ct.nConnPerHidden_Start];
nc_end   = [ct.nConnPerHidden_End];
nconn  = unique([mSets.nConns]); nc=length(nconn);
clear('ac','ct');

calc_density = @(s,ncs,nce) (s./sqrt(ncs./nce));
density = unique(calc_density(sigmas, nc_start, nc_end)); nd=length(density);
guru_assert( length(density) == length(unique(nc_start ./ nc_end))*unique(sigmas) );
clear('sigmas','ns');

% Second measure:nconn

freqs1D= tstm(1).stats.rej.ac.ffts.orig.freqs_1D; nf = length(freqs1D);
nhid   = [mSets(1).nHidden/mSets(1).hpl mSets(1).hpl];
smidx  = 3; % lotsa smoothing


%%=======================
% Collect stats
%========================
rejs        = nan(nc, nd);  % rejections
ipd_spread  = nan(nc, nd);  % ipd
ipd_nearest = nan(nc, nd);  % ipd
perf        = cell(nc, nd);
pow1D_trn   = nan(nc, nd, nf);
pow1D_tst   = nan(nc, nd, nf);

pow1D_o   = reshape(tstm(1).stats.rej.ac.ffts.orig.power1D{1}(smidx,:,:), [1 nf]);

for mi=1:numel(tstm)
    ci = find(nconn  == mSets(mi).nConns);
    di = find(density == calc_density(mSets(mi).sigma(1), mSets(mi).ac.ct.nConnPerHidden_Start, mSets(mi).ac.ct.nConnPerHidden_End));
    guru_assert(length(ci)==1);
    guru_assert(length(di)==1);
    
    
    for ii=1:2
        if ~isempty(tstm(mi).stats.raw)
%            raw = [tst_stats.raw]; r=[raw.r];
            rejs(ci,di) = nnz(sum(tstm(mi).stats.raw.r{ii},2));
        elseif ~isempty(trnm(mi).stats.raw)
            rejs(ci,di) = nnz(sum(trnm(mi).stats.raw.r,2));
        else
            rejs(ci,di) = 0;
        end;
        if rejs(ci,di)>=mSets(1).runs, continue; end;

        pow1D_trn(ci,di,:) = mean(trnm(mi).stats.rej.ac.ffts.model.power1D{ii}(smidx,:,:),2);
        pow1D_tst(ci,di,:) = mean(tstm(mi).stats.rej.ac.ffts.model.power1D{ii}(smidx,:,:),2);
         
        ipd_spread(ci,di) = tstm(mi).stats.rej.ac.ipd.from_center_mean(ii);
        ipd_nearest(ci,di) = tstm(mi).stats.rej.ac.ipd.nearest_neighbor_mean(ii);
        
        if isfield(tstm(mi).stats.rej.basics, 'bars')
            perf{ci,di} = tstm(mi).stats.rej.basics.bars(3:4,rejs(ci,di)<mSets(1).runs)';
            perf{ci,di} = perf{ci,di}./sum(perf{ci,di}); % normalize bars
        elseif isfield(tstm(mi).stats.rej.basics,'perf')
            perf{ci,di} = mean(tstm(mi).stats.rej.basics.perf.test{ii}{1}(:));
        end;
    end;
end;

% fill in blanks with nan
for ii=1:numel(perf), if isempty(perf{ii}), perf{ii} = nan(size(perf{1})); end; end;


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
clear('mSets','trnm','tstm');
clear('ci','ci2','di','di2','mi','ii');

% A little trickery: alias density as sigmas
sigmas = density;
ns = nd;

% Now save off the workspace
filout = [tempname() '.mat'];
save(filout);
    
