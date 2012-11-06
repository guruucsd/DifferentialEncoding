function figs = de_PlotDistributions(mSets, stats)


  figs        = de_NewFig('dummy');

  figs(end+1) = de_PlotGenericDistributions(mSets, stats.cxns_in,  'cxns_in');
  figs(end+1) = de_PlotGenericDistributions(mSets, stats.cxns_out, 'cxns_out');

  figs(end+1) = de_PlotGenericDistributions(mSets, stats.weights_in,  'weights_in');
  figs(end+1) = de_PlotGenericDistributions(mSets, stats.weights_out, 'weights_out');

function fig = de_PlotGenericDistributions(mSets, data, figname)

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
