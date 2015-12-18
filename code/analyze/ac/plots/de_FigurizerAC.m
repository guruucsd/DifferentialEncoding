function figs = de_FigurizerAC(mSets, mss, stats)

  if (isfield(mSets.data, 'test')), ds = 'test';
  else,                             ds = 'train'; end;
  selectedImages = de_SelectImages(mSets.data.(ds), 20);

  % Plot default
  if (guru_contains('default', mSets.plots))
    default_plots = {'train-iters'};
    mSets.plots = setdiff(unique({mSets.plots{:} default_plots{:}}), {'default'});
  end;

  % Set up dummy struct
  figs = de_NewFig('dummy');


  % Plots over the whole expt
  figs = [ figs de_DoPlot('train-error',   'de_PlotTrainErrorAC',   mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-time',    'de_PlotTrainTimeAC',    mSets, mSets, stats) ];
  figs = [ figs de_DoPlot('train-iters',   'de_PlotTrainItersAC',   mSets, mSets, stats) ];
  %figs = [ figs de_DoPlot('connectivity',  'de_PlotConnectivity', mSets, mSets, stats.rej.ac.connectivity) ];
  figs = [ figs de_DoPlot('ffts',          'de_PlotFFTs',         mSets, mSets, stats.rej.ac.ffts) ];
  figs = [ figs de_DoPlot('distns',        'de_PlotDistributions',mSets, mSets, stats.rej.ac.distns) ];

  % Plot the original images
  figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, mSets, mSets.data.(ds).X(1:end-1,selectedImages),  mSets.data.(ds).XLAB(selectedImages)) ];

  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
  for ss=1:length(mSets.sigma)
    ms = mss{ss};
% Plot the
    if (~isempty(stats.rej.ac.images.(ds))),  figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, ms, stats.rej.ac.images.(ds){ss},  mSets.data.(ds).XLAB(selectedImages)) ];
    elseif ismember('images',mSets.plots), warning('Must get images in stats to run plots.'); end;

%    if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.test) ];
%    else,                             figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.train) ]; end;


%    if (isfield(mSets.data,  'test')), figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.test) ];
%    else,                              figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.train) ]; end;

    if (~isempty(stats.rej.ac.huencs.(ds))),  figs = [ figs de_DoPlot('hu-encodings', 'de_PlotHUEncoding', mSets, ms, stats.rej.ac.huencs.(ds){ss}) ];
    elseif ismember('hu-encodings', mSets.plots), warning('Must get hu encodings in stats to run plots.');
    end;

    if (~isempty(stats.rej.ac.huouts.(ds))),  figs = [ figs de_DoPlot('hu-output', 'de_PlotHUOutput', mSets, ms, stats.rej.ac.huouts.(ds){ss}) ];
    elseif ismember('hu-output', mSets.plots), warning('Must get hu outputs in stats to run plots.'); end;

    if (~isempty(stats.rej.ac.sta)),  figs = [ figs de_DoPlot('sta', 'de_PlotSTA', mSets, ms, stats.rej.ac.sta{ss}) ];
    elseif ismember('sta', mSets.plots), warning('Must get sta in stats to run plots.'); end;

  end;  %ss

