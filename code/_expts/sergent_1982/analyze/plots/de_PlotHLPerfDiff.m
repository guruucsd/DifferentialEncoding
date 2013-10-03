function fig = de_PlotHLPerfDiff(allstats, nHidden, nConns)

  perfdiff = de_StatsHLPerfDiff(allstats);

  fig.name = 'perfdiff';
  fig.handle = figure;
  imagesc(perfdiff); colorbar;

  title('Performance Difference between LH and RH nets (LH-RH) (conditions L+S- and L-S+)');
  xlabel('# connections'); ylabel('# hidden nodes');
  set(gca, 'xtick', 1:length(nConns),  'xticklabel', nConns);
  set(gca, 'ytick', 1:length(nHidden), 'yticklabel', nHidden);

