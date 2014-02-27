load runs\adhoc\S1_orig_h14_c7-14\S1_orig.mat;
mSets = modelSettings;
tidx = [mSets.data.aux.idx.LpSm mSets.data.aux.idx.LmSp mSets.data.aux.idx.LpSp mSets.data.aux.idx.LmSm];

  for i=1:2
    LS = stats.raw.ls{i};

    data = (LS(:,tidx)./repmat(mean(LS(:,tidx),2), [1 length(tidx)]))/length(tidx);

    ncols = 2;
    nrows = ceil(length(tidx)/ncols);
    sigma = modelSettings.sigma(i);
    figure;
    for j=1:length(tidx)
      bins = de_SmartBins(data(:,j), 2);

      [a,b] = histc(data(:,j),bins);
      a = a/length(data(:,j));

      subplot(nrows,ncols,j);
      bar(bins,a);
      %set(gca, 'ylim',[0 0.06]);
      set(gca, 'xlim', [0 bins(end)+(bins(end)-bins(end-1))/2]);
      hold on;
      title(sprintf('%s: Err dist''n, o=%4.1f', mSets.data.aux.TLBL{tidx(j)}, sigma));
    end;
end;
