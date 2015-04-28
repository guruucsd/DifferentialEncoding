function neighbor_dist(desired_neighbor_dist, nConns, npts)

params = { 'nInput', [35 35], 'nHidden', 1, 'hpl', 1, 'distn', {'norme'}, 'mu', 0, ...
           'ac', struct('debug',1:10,'tol',1,'useBias',0), ...
           'nConns', nConns};

%cost_fn = @(sig) abs(desired_neighbor_dist -
%estimate_spread(struct('sigma',sig,params{:})));
%sig = fminsearch(cost_fn,2,optimset('Display','iter'));
sig=3;
[a,b,c]=estimate_spread(struct('sigma',sig,params{:}),npts);
bins = 0:0.1:10;%unique(c(:));
figure;
%bar(bins, hist(c(:), bins);
dist = hist(c(:), bins);
bar(bins, dist./sum(dist(:)))
hold on;
title(sprintf('\\mu = %5.3f', mean(c(:))));
set(gca, 'xlim', [0 11]);