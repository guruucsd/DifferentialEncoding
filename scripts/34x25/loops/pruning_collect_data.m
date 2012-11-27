function pruning_analysis(trn, tst, plt, dbg)
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

trn   = reshape([trn{:}], size(trn));
tst   = reshape([tst{:}], size(tst));
mSets = reshape([trn.mSets], size(trn));
sigmas = [mSets.sigma]; sigmas = reshape(sigmas(1:2:end), size(trn));
nconn = reshape([mSets.nConns], size(tst));

sigmas = unique(sigmas); ns=length(sigmas);
nconn  = unique(nconn);  nc=length(nconn);
trn2 = cell(ns,nc); tst2 = cell(ns,nc);
for mi=1:numel(trn)
    si = find(sigmas == mSets(mi).sigma(1));
    ci = find(nconn  == mSets(mi).nConns);
    trn2{si,ci} = [trn2{si,ci} trn(mi)];
    tst2{si,ci} = [tst2{si,ci} tst(mi)];
end;

loop_analysis(trn2,tst2)

% sigmas are the same on axis 1, nconn on axis 2

keyboard

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


    
