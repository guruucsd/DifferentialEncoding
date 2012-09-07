function figs = de_DEFigurizerLSB(mSets, mss, stats, figs)  
  
  if (ismember(1, mSets.debug)), fprintf('Doing selected LSB plots...\n'); end;
  
  % Plots
%  figs = de_DoPlot('reza',        'de_PlotHLReza',                        figs, mSets, mSets, stats.raw.ls, stats.raw.errAC, mSets.sigma);
%  figs = de_DoPlot('error-trend', 'de_PlotHLErrorTrend',                  figs, mSets, mSets, stats.raw.ls, mSets.sigma);
%  figs = de_DoPlot('tcptt',       'de_PlotHLTrainingCurves_PerTrialType', figs, mSets, mss, stats.raw.r, mSets.errorType);
%  figs = de_DoPlot('ls-bars-raw', 'de_PlotHLBars',                        figs, mSets, mSets, stats.raw.ls);
%  figs = de_DoPlot('ls-bars',     'de_PlotHLBars',                        figs, mSets, mSets, stats.rej.ls, mss, stats.raw.r);
%  figs = de_DoPlot('ls-bars-div', 'de_PlotHLBarsDivided',                 figs, mSets, mSets, stats.rej.ls, mss, stats.raw.r);

  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
%  for ss=1:length(mSets.sigma)
%    ms = mss(:,ss);

    % Used to plot training curves
%    figs = de_DoPlot('tc',        'de_PlotHLTrainingCurves',              figs, mSets, ms, stats.raw.r{ss}, mSets.errorType);
%    figs = de_DoPlot('tcptt',     'de_PlotHLTrainingCurves_PerTrialType', figs, mSets, ms, stats.raw.r{ss}, mSets.errorType);
%    figs = de_DoPlot('ls-distns', 'de_PlotHLDistns',                      figs, mSets, mSets, stats.raw.ls{ss}, mSets.sigma(ss));
%    figs = de_DoPlot('outliers',  'de_PlotHLOutliers',                    figs, mSets, mSets, stats.raw.ls{ss}, mSets.sigma(ss), stats.raw.r{ss});
%  end;  %ss
  
