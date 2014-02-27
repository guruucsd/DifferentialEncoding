function figs = de_FigurizerP(mSets, mss, stats)
%
%

  % Plot default
  if (guru_contains('default', mSets.plots))
    default_plots = {'train-error'};
    mSets.plots = setdiff(unique({mSets.plots{:} default_plots{:}}), {'default'});
  end;

  % Set up dummy struct
  figs = de_NewFig('dummy');

  % Plots over the whole expt
  figs = [ figs de_DoPlot('train-error',   'de_PlotTrainErrorP',   mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-time',    'de_PlotTrainTimeP',    mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-iters',   'de_PlotTrainItersP',   mSets, mSets, stats) ];
