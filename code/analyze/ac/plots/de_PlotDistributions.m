function figs = de_PlotDistributions(mSets, stats)


  figs        = de_NewFig('dummy');

  % Plot 2D average weights/connections, in 2D
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_in,  'cxns_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.cxns_out, 'cxns_out_mean2D');

  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_in,  'weights_in_mean2D');
  figs(end+1) = de_PlotMeanDistributions2D(mSets, stats.weights_out, 'weights_out_mean2D');

  weight_bins = linspace(-2,2,10);
  connection_bins = linspace(0,0.10,25);

  % Plot radial distribution of weights/connections (as a surface; x-axis=distance, y-axis=weight value bins, z-axis=p(x&y))
  figs(end+1) = de_PlotDistributions1D(mSets, stats.cxns_in, connection_bins, 'cxns_in_distn', 'cxn');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.cxns_out, connection_bins, 'cxns_out_distn', 'cxn');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.weights_in, weight_bins, 'weights_in_distn', 'weight');
  figs(end+1) = de_PlotDistributions1D(mSets, stats.weights_out, weight_bins, 'weights_out_distn', 'weight');

  % Plot distribution of weights
  n_dist_bins = 25;
  figs(end+1) = de_PlotMeanDistributions1D(mSets, stats.cxns_in, n_dist_bins, 'cxns_in_hist');


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
    subplot(3, 1, 1 + (si > 1));
    de_PlotDistributions1D_subplot(squeeze(distn_img(si,:,:)), dist1D, bins, datalbl);
  end;

  subplot(3,1,3);
  de_PlotDistributions1D_subplot(-squeeze(diff(distn_img([1 end], :, :),1)), dist1D, bins, datalbl);


function de_PlotDistributions1D_subplot(distn_img, dist1D, bins, datalbl)
%
  imagesc(distn_img, [-0.5 0.5]);
  ylabel(sprintf('P(%s)', datalbl)); xlabel('distance');
  set(gca, 'yticklabel', guru_csprintf('%3.2f', num2cell(bins(get(gca,'ytick')))));
  set(gca, 'xticklabel', guru_csprintf('%4.3f', num2cell(dist1D(get(gca,'xtick')))));



function fig = de_PlotMeanDistributions1D(mSets, data, nbins, figname)
% Probability of a connection or 
  fig = de_NewFig(figname);

  [dist1D,rho] = guru_pixeldist(size(data{1}));
  bins = linspace(0, dist1D(end), nbins);

  [~,idx] = histc(rho, bins);
  data_hist1 = zeros(size(bins));
  data_hist2 = zeros(size(bins));
  for bi=1:nbins
    data_hist1(bi) = sum(data{1}(idx(:)==bi));
    data_hist2(bi) = sum(data{end}(idx(:)==bi));
  end;
  data_hist_diff = data_hist1-data_hist2;

<<<<<<< HEAD
  subplot(1,3,1);bar(bins, data_hist1);
  subplot(1,3,2);bar(bins, data_hist2);
  subplot(1,3,3);bar(bins, data_hist_diff);
=======
  subplot(1,3,1); bar(bins, data_hist1);
  subplot(1,3,2); bar(bins, data_hist2);
  subplot(1,3,3); bar(bins, data_hist_diff);
>>>>>>> 58f2077f22e7a2a1cd20991965715c8d83bf8a3c


function fig = de_PlotMeanDistributions2D(mSets, data, figname)
%

  fig = de_NewFig(figname);

  % Normalize to make these comparable histograms
  data1 = data{1};% / sum(data{1}(:));
  data2 = data{end};% / sum(data{end}(:));

  max1 = max(data1(:));
  max2 = max(data2(:));

  % Defaults
  clim = max(max1,max2)*[-1 1];

  % When the distribution is norme2,
  %   there is a single location with an extreme value;
  %   make sure when we get the clim, we take care
  %   to exclude those extreme values
  if nnz(data{1}>=max1/2)==1 ...
    && nnz(data{2}>=max2/2)==1

    maxidx1 = find(data1>=max1);
    maxidx2 = find(data2>=max2);

    data1(maxidx1) = 0;%-data1(data1>=max1);
    data2(maxidx2) = 0;%-data2(data2>=max2);

    max1 = max(data1(:));
    max2 = max(data2(:));
    clim = max(max1, max2) * [-1 1];

    data1(maxidx1) = max1;
    data2(maxidx2) = max2;
  end;

  % compute difference
  dff = data1 - data2;
  clim_dff = max(abs(dff(:))) * [-1 1];

  % zoom in on center of image
  xidx = round(size(data1,1)/4 + [1:mSets.nInput(1)]);
  yidx = round(size(data1,2)/4 + [1:mSets.nInput(2)]);

  subplot(1,3,1);
  imagesc(data1(xidx,yidx), clim); set(gca, 'xtick', [], 'ytick', []);
  title(mSets.out.titles{1}, 'FontSize', 16);

  subplot(1,3,2);
  imagesc(data2(xidx,yidx), clim); set(gca, 'xtick', [], 'ytick', []);
  title(mSets.out.titles{end}, 'FontSize', 16);

  subplot(1,3,3);
  imagesc(dff(xidx,yidx), clim_dff); set(gca, 'xtick', [], 'ytick', []);
  title('RH - LH', 'FontSize', 16);
