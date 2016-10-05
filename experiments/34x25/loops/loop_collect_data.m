function filout = loop_collect_data(trn, tst)

if ~exist('de_PlotFFTs','file')
    if ~exist('uber_sergent_args','file'), addpath('../sergent_1982'); end;
    uber_sergent_args();
end;


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


% Clean up workspace
clear('mSets','trn','tst');
clear('ci','ci2','si','si2');

% Now save off the workspace
filout = [tempname() '.mat'];
save(filout);
