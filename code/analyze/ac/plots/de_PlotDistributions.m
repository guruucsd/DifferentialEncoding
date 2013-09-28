function figs = de_PlotDistributions(mSets, stats)


  figs        = de_NewFig('dummy');

  % Plot 2D average weights/connections, in 2D
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_in,  'cxns_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_out, 'cxns_out_mean2D');

  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_in,  'weights_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_out, 'weights_out_mean2D');

  weight_bins = linspace(-2,2,10);
  connection_bins = linspace(0,0.15,10);

  % Plot radial distribution of weights/connections (as a surface; x-axis=distance, y-axis=weight value bins, z-axis=p(x&y))
  figs(end+1) = de_PlotDistributions1D(mSets, stats.cxns_in, connection_bins, 'cxns_in_distn', 'cxn');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.cxns_out, connection_bins, 'cxns_out_distn', 'cxn');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.weights_in, weight_bins, 'weights_in_distn', 'weight');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.weights_out, weight_bins, 'weights_out_distn', 'weight');

  % Plot distribution of weights
  figs(end+1) = de_PlotMeanDistributions1D(mSets, stats.cxns_in, connection_bins, 'cxns_in_hist');


function fig = de_PlotDistributions1D(mSets, data, bins, figname, datalbl)
% Show probability connectivity/weights as a function of distance
%
% Assume center of 2D data as center; all distances computed from there

  fig = de_NewFig(figname);

  [dist1D,rho] = guru_pixeldist(size(data{1}));
  nBins = length(bins); nDist = floor(length(dist1D)/10);

  % Collect the samples & create each row of the image
  distn_img = zeros(2, nBins, nDist);
  for si=[1 length(data)]
    dsamps      = cell(nDist,1);
    for di=1:nDist
      dsamps{di} = data{si}(rho==dist1D(di));
      distn_img(si, :, di) = histc(dsamps{di}, bins)/length(dsamps{di});
    end;

    % Show the surface
    subplot(3,1,si);
    de_PlotDistributions1D_subplot(squeeze(distn_img(si,:,:)), dist1D, bins, datalbl);
  end;
  
  subplot(3,1,3);
  de_PlotDistributions1D_subplot(-squeeze(diff(distn_img,1)), dist1D, bins, datalbl);

function de_PlotDistributions1D_subplot(distn_img, dist1D, bins, datalbl)

  imagesc(distn_img, [-0.5 0.5]);
  ylabel(sprintf('P(%s)', datalbl)); xlabel('distance');
  set(gca, 'yticklabel', guru_csprintf('%3.2f', num2cell(bins(get(gca,'ytick')))));
  set(gca, 'xticklabel', guru_csprintf('%4.3f', num2cell(dist1D(get(gca,'xtick')))));



function fig = de_PlotMeanDistributions1D(mSets, data, bins, figname)
% Probability of a connection or 
  fig = de_NewFig(figname);

  data_hist1  = histc(data{1}(:), bins)/numel(data{1});
  data_hist2  = histc(data{end}(:), bins)/numel(data{end});
  data_hist_diff = data_hist1-data_hist2;
  
  subplot(1,3,1);bar(bins, data_hist1);
  subplot(1,3,2);bar(bins, data_hist2);
  subplot(1,3,3);bar(bins, data_hist_diff);


function fig = de_PlotMeanDistributions2D(mSets, data, figname)
%

  fig = de_NewFig(figname);
  max1 = max(data{1}(:));
  max2 = max(data{end}(:));

  % Defaults
  clim = max(max1,max2)*[-1 1];
  d1 = data{1};
  d2 = data{2};

  % When the distribution is norme2,
  %   there is a single location with an extreme value;
  %   make sure when we get the clim, we take care
  %   to exclude those extreme values
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
