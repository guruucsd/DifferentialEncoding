function figs = de_PlotDistributions(mSets, stats)


  figs        = de_NewFig('dummy');

  % Plot 2D average weights/connections, in 2D
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_in,  'cxns_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_out, 'cxns_out_mean2D');

  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_in,  'weights_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_out, 'weights_out_mean2D');

  weight_bins = linspace(-2,2,10);
  connection_bins = linspace(0,1,10);

  % Plot radial distribution of weights/connections (as a surface; x-axis=distance, y-axis=weight value bins, z-axis=p(x&y))
  figs(end+1) = de_PlotDistributions1D(mSets, stats.cxns_in, connection_bins, 'cxns_in_distn');

  % Plot distribution of weights
  figs(end+1) = de_PlotMeanDistributions1D(mSets, stats.cxns_in, connection_bins, 'cxns_in_hist');


function fig = de_PlotDistributions1D(mSets, data, bins, figname)
% Assume center of 2D data as center; all distances computed from there

  [freq1D,rho] = guru_pixeldist(size(data));
  nBins = length(bins); nFreq = length(freq1D);

  % Collect the samples & create each row of the image
  fsamps      = cell(nFreq,1);
  distn_surf = zeros(nFreq, nBins);
  for fi=1:nFreq
    fsamps{fi} = data(rho==freq1D(fi));
    distn_surf(fi,:) = histc(fsamps{fi}, bins)/length(fsamps{fi});
  end;

  % Show the surface
  surf(repmat(freq1D', [1 nBins]), repmat(bins, [nFreq 1]), distn_surf);


function fig = de_PlotMeanDistributions1D(mSets, data, bins, figname)
  data_hist  = histc(data(:), bins)/numel(data);

  fig = de_NewFig(figname);
  bar(bins, data_hist);


function fig = de_PlotMeanDistributions2D(mSets, data, figname)

  fig = de_NewFig(figname);
  max1 = max(data{1}(:));
  max2 = max(data{end}(:));

  % Defaults
  clim = max(max1,max2)*[-1 1];
  d1 = data{1};
  d2 = data{2};

  % 
  if nnz(data{1}>=max1/2)==1 ...
    && nnz(data{2}>=max2/2)==1

    maxidx1 = find(d1>=max1);
    maxidx2 = find(d2>=max2);

    d1(maxidx1) = 0;%-d1(d1>=max1);
    d2(maxidx2) = 0;%-d2(d2>=max2);

    max1 = max(d1(:));
    max2 = max(d2(:));
    clim = max(max1, max2) * [-1 1];

    d1(maxidx1) = max1;
    d2(maxidx2) = max2;
  end;

  % compute difference
  dff = d1-d2;
  clim_dff = max(abs(dff(:))) * [-1 1];

  % zoom in on center of image
  xidx = round(size(d1,1)/4 + [1:mSets.nInput(1)]);
  yidx = round(size(d1,2)/4 + [1:mSets.nInput(2)]);

  subplot(1,3,1);
  imagesc(d1(xidx,yidx), clim); set(gca, 'xtick', [], 'ytick', []);
  title('LSF (RH)', 'FontSize', 16);

  subplot(1,3,2);
  imagesc(d2(xidx,yidx), clim); set(gca, 'xtick', [], 'ytick', []);
  title('Full-fidelity (LH)', 'FontSize', 16);

  subplot(1,3,3);
  imagesc(dff(xidx,yidx), clim_dff); set(gca, 'xtick', [], 'ytick', []);
  title('RH - LH', 'FontSize', 16);
