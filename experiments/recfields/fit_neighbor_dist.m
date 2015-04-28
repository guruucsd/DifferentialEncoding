function [gam_params, emp_mean] = fit_neighbor_dist(sig, nConns, npts, showfig)
% Fit gamma distribution to minimum neighbor distances.
%
% 
if ~exist('showfig','var'), showfig = false; end;

params = { 'nInput', [35 35], 'nHidden', 1, 'hpl', 1, 'distn', {'norme'}, 'mu', 0, ...
           'ac', struct('debug',1:10,'tol',1,'useBias',0), ...
           'nConns', nConns};

[~, ~, min_ipd]=estimate_min_spread(struct('sigma',sig,params{:}),npts);
bins = 0:0.1:10;%unique(min_ipd(:));
dist = hist(min_ipd(:), bins);

[fitfn] = guru_getfitfns('gamma', 0, showfig);

gam_params = fitfn(dist,bins);
emp_mean = mean(min_ipd(:));

