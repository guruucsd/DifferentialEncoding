function fig = de_PlotHLHumanFit(allstats, nHidden, nConns)
%

  % Grab the relevant stats the figure
  humfit = de_StatsHLHumanFitf(allstats);

  % Produce the figure
  fig.name   = 'humfit';
  fig.handle = figure;
  imagesc(humfit); colorbar;

  title('Fit With Human Data (conditions L+S- and L-S+');
  xlabel('# connections'); ylabel('# hidden nodes');
  set(gca, 'xtick', 1:length(nConns),  'xticklabel', nConns);
  set(gca, 'ytick', 1:length(nHidden), 'yticklabel', nHidden);
