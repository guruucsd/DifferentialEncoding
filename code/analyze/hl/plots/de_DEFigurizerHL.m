function figs = de_DEFigurizerHL(mSets, mss, stats)  
%

  % Plot default
  if (guru_contains('default', mSets.plots))
    default_plots = {'ls-bars', 'ls-bars-div', 'ls-distns', 'outliers', 'tc'};
    mSets.plots = setdiff(unique({mSets.plots{:} default_plots{:}}), {'default'});
  end;
  
  
  % Dummy fig
  figs = struct('name',[],'handle',[],'size',[]);
  figs = figs([]);
  
  % Plots
  figs = [figs de_DoPlot('reza',        'de_PlotHLReza',                        mSets, mSets, stats.raw.basics.ls, stats.raw.err.AC, mSets.sigma) ];
  figs = [figs de_DoPlot('error-trend', 'de_PlotHLErrorTrend',                  mSets, mSets, stats.raw.basics.ls, mSets.sigma) ];
  figs = [figs de_DoPlot('tcptt',       'de_PlotHLTrainingCurves_PerTrialType', mSets, de_DoRejectionsHL(mss, stats.raw.r), mSets.errorType) ];
  figs = [figs de_DoPlot('ls-bars-raw', 'de_PlotHLBars',                        mSets, mSets, stats.raw) ];
  figs = [figs de_DoPlot('ls-bars',     'de_PlotHLBars',                        mSets, mSets, stats.rej) ];
  figs = [figs de_DoPlot('ls-bars',     'de_PlotHLBarsZoomed',                  mSets, mSets, stats.rej) ];
  figs = [figs de_DoPlot('ls-bars-div', 'de_PlotHLBarsDivided',                 mSets, mSets, stats.rej) ];

  %----------------
  % Loop over sigmas
  %----------------
  for ss=1:length(mSets.sigma)
    ms = mss{ss};
    
    % Used to plot training curves
    figs = [figs de_DoPlot('tc',        'de_PlotHLTrainingCurves',              mSets, de_DoRejectionsHL(ms, stats.raw.r), mSets.errorType) ];
    %figs = [figs de_DoPlot('tcptt',     'de_PlotHLTrainingCurves_PerTrialType', mSets, de_DoRejectionsHL(ms, stats.raw.r), mSets.errorType) ];
    figs = [figs de_DoPlot('ls-distns', 'de_PlotHLDistns',                      mSets, mSets, stats.raw.basics.ls{ss}, mSets.sigma(ss)) ];
    figs = [figs de_DoPlot('outliers',  'de_PlotHLOutliers',                    mSets, mSets, stats.raw.basics.ls{ss}, mSets.sigma(ss), stats.raw.r{ss}) ];
    
    if     (isfield(stats.rej.huacts, 'test')  && length(stats.rej.huacts.test)>0),  figs = [figs de_DoPlot('optimal',   'de_PlotHLOptimal', mSets, stats.rej.huacts.test{ss},  mSets.data.test) ];
    elseif (isfield(stats.rej.huacts, 'train') && length(stats.rej.huacts.train)>0), figs = [figs de_DoPlot('optimal',   'de_PlotHLOptimal', mSets, stats.rej.huacts.train{ss}, mSets.data.train)]; end;
  end;  %ss
