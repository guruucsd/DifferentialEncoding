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

if ~exist('plt','var'), plt = {'all'}; end;
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


calc_density = @(s,ncs,nce) (s./sqrt(ncs./nce));
density = unique(calc_density(sigmas, nc_start, nc_end)); nd=length(density);
guru_assert( length(density) == length(unique(nc_start ./ nc_end))*unique(sigmas) );
clear('sigmas','ns');

% Second measure:nconn

freqs1D= tst(1).stats.rej.ac.ffts.orig.freqs_1D; nf = length(freqs1D);
nhid   = [mSets(1).nHidden/mSets(1).hpl mSets(1).hpl];
smidx  = 3; % lotsa smoothing


% redistribute trn/tst into [nc X nd] matrix
newidx = zeros(nc,nd);
for mi=1:numel(trn)
    ci = find(nconn  == mSets(mi).nConns);
    di = find(density == calc_density(mSets(mi).sigma(1), mSets(mi).ac.ct.nConnPerHidden_Start, mSets(mi).ac.ct.nConnPerHidden_End));
    newidx(ci,di) = mi;
end;
guru_assert(nnz(newidx)==numel(tst);

%%=======================
% Collect stats
%========================
rejs        = nan(nc, nd);  % rejections
ipd_spread  = nan(nc, nd);  % ipd
ipd_nearest = nan(nc, nd);  % ipd
perf        = cell(nc, nd);
pow1D_trn   = nan(nc, nd, nf);
pow1D_tst   = nan(nc, nd, nf);

pow1D_o   = reshape(tst(1).stats.rej.ac.ffts.orig.power1D{1}(smidx,:,:), [1 nf]);
for ci=1:nc
    for di=1:nd
        trn = trnm(newidx(ci,di));
        tst = tst,(newidx(ci,di));
        if ~isempty(tst.stats.raw)
            rejs(ci,di) = nnz(sum(tst.stats.raw.r{di},2));
        elseif ~isempty(trn.stats.raw)
            rejs(ci,di) = nnz(sum(trn.stats.raw.r{di},2));
        else
            rejs(ci,di) = 0;
        end;
        if rejs(ci,di)>=mSets(1).runs, continue; end;

        pow1D_trn(ci,di,:) = mean(trn.stats.rej.ac.ffts.model.power1D{di}(smidx,:,:),2);
        pow1D_tst(ci,di,:) = mean(tst.stats.rej.ac.ffts.model.power1D{di}(smidx,:,:),2);
         
        ipd_spread(ci,di) = tst.stats.rej.ac.ipd.from_center_mean(di);
        ipd_nearest(ci,di) = tst.stats.rej.ac.ipd.nearest_neighbor_mean(di);
        
        if isfield(tst.stats.rej.basics, 'bars')
            perf{ci,di} = tst.stats.rej.basics.bars(3:4,sum(rejs(ci,:)<mSets(1).runs))';
            perf{ci,di} = perf{ci,di}./sum(perf{ci,di}); % normalize bars
        elseif isfield(tst.stats.rej.basics,'perf')
            perf{ci,di} = mean(tst.stats.rej.basics.perf.test{di}{1}(:));
        end;
    end;
end;


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

    
filout = [tempfile() '.mat'];
save(filout);

    
