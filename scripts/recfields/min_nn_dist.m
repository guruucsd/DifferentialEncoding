function [gam_params, emp_mean] = min_nn_dist(sig, nConns, npts, showfig)

if ~exist('showfig','var'), showfig = false; end;

params = { 'nInput', [35 35], 'nHidden', 1, 'hpl', 1, 'distn', {{'norme'}}, 'mu', 0, ...
           'ac', struct('debug',1:10,'tol',1,'useBias',0), ...
           'nConns', nConns};
       
[~,~,c]=estimate_min_spread(struct('sigma',sig,params{:}),npts);
bins = 0:0.1:10;%unique(c(:));
dist = hist(c(:), bins);

[fitfn] = guru_getfitfns('gamma', 0, showfig);

gam_params = fitfn(dist,bins);
emp_mean = mean(c(:));

