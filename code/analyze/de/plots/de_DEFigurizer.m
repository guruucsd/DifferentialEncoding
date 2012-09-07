function figs = de_DEFigurizer(mSets, mss, stats)  
%
%

  % Plot default
  if (guru_contains('default', mSets.plots))
    default_plots = {'train-error', 'train-iters', 'images', 'connectivity'};
    mSets.plots = setdiff(unique({mSets.plots{:} default_plots{:}}), {'default'});
  end;


  % Set up dummy struct  
  figs = struct('name',[],'handle',[],'size',[]);
  figs = figs([]);

  % Plots over the whole expt
  figs = [ figs de_DoPlot('train-error',   'de_PlotTrainError',   mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-time',    'de_PlotTrainTime',    mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-iters',   'de_PlotTrainIters',   mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('connectivity',  'de_PlotConnectivity_Avg2Dto1D', mSets, mSets, mss) ];
  if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('ffts',          'de_PlotFFTs',         mSets, mSets, stats.rej.ffts.test) ];
  else,                             figs = [ figs de_DoPlot('ffts',          'de_PlotFFTs',         mSets, mSets, stats.rej.ffts.train) ]; end;
  
  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
  for ss=1:length(mSets.sigma)
    ms = mss{ss};
    
    if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, ms, mSets.data.test) ]; 
    else,                             figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, ms, mSets.data.train) ]; end;
    if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.test) ]; 
    else,                             figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.train) ]; end;
    
    
    if (isfield(mSets.data,  'test')), figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.test) ];
    else,                              figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.train) ]; end;
    figs = [ figs de_DoPlot('connectivity',  'de_PlotConnectivity',           mSets, ms) ];
    figs = [ figs de_DoPlot('hu-activity',   'de_PlotHUActivity',             mSets, ms) ];
  end;  %ss

