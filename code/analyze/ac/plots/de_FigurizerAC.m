function figs = de_FigurizerAC(mSets, mss, stats) 

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
  figs = [ figs de_DoPlot('connectivity',  'de_PlotConnectivity', mSets, mSets, mss) ];
%  figs = [ figs de_DoPlot('connectivity',  'de_PlotConnectivity_Avg2Dto1D', mSets, mSets, mss) ];
  if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('ffts',          'de_PlotFFTs_InPowerSpace',         mSets, mSets, stats.rej.ac.ffts.test) ];
  else,                             figs = [ figs de_DoPlot('ffts',          'de_PlotFFTs_InPowerSpace',         mSets, mSets, stats.rej.ac.ffts.train) ]; end;
  
  % Plot the original images
  if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, mSets, mSets.data.test.X(1:end-1,:),  mSets.data.test.XLAB) ]; 
  else,                             figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, mSets, mSets.data.train.X(1:end-1,:), mSets.data.train.XLAB) ]; end;

    
  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
  for ss=1:length(mSets.sigma)
    ms = mss{ss};
    
    % Plot the 
    if (isfield(stats.rej.ac.images, 'test'))
        if (~isempty(stats.rej.ac.images.test)),  figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, ms, stats.rej.ac.images.test{ss}) ]; end;
    elseif (~isempty(stats.rej.ac.images.train)), figs = [ figs de_DoPlot('images',      'de_PlotOutputImages',     mSets, ms, stats.rej.ac.images.train{ss}) ]; 
    else, warning('Must get images in stats to run plots.');
    end;
    
%    if (isfield(mSets.data, 'test')), figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.test) ]; 
%    else,                             figs = [ figs de_DoPlot('image-diffs', 'de_PlotOutputImageDiffs', mSets, ms, mSets.data.train) ]; end;
    
    
%    if (isfield(mSets.data,  'test')), figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.test) ];
%    else,                              figs = [ figs de_DoPlot('image-threshd', 'de_PlotOutputImagesThreshd', mSets, ms, mSets.data.train) ]; end;

%    if (isfield(stats.rej.ac.huencs,  'test'))
%         if (~isempty(stats.rej.ac.huencs.test)),  figs = [ figs de_DoPlot('hu-encoding', 'de_PlotHUEncoding', mSets, ms, stats.rej.ac.huencs.test{ss}) ]; end;
%    elseif  (~isempty(stats.rej.ac.huencs.train)), figs = [ figs de_DoPlot('hu-encoding', 'de_PlotHUEncoding', mSets, ms, stats.rej.ac.huencs.train{ss}) ]; 
%    else, warning('Must get hu encodings in stats to run plots.'); 
%    end;
    
    if (isfield(stats.rej.ac.huouts,  'test'))
         if (~isempty(stats.rej.ac.huouts.test)),  figs = [ figs de_DoPlot('hu-output', 'de_PlotHUOutput', mSets, ms, stats.rej.ac.huouts.test{ss}) ]; end;
    elseif  (~isempty(stats.rej.ac.huouts.train)), figs = [ figs de_DoPlot('hu-output', 'de_PlotHUOutput', mSets, ms, stats.rej.ac.huouts.train{ss}) ];
    else, warning('Must get hu outputs in stats to run plots.'); 
    end;
  end;  %ss

