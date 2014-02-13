function [success,mSets] = de_SaveAll(mSets, models, stats, figs)
%
%

  if (exist('models','var') && isempty(models)), clear('models'); end;
  if (exist('stats','var')  && isempty(stats)),  clear('stats'); end;
  if (exist('figs','var')   && isempty(figs)),   clear('figs'); end;

  % Check to see if we want to be saving things.
  if (~isfield(mSets, 'out'))
    fprintf('Exiting without saving.\n');
    return;
  elseif (~isfield(mSets.out, 'stem'))
    error('Must set mSets.out.stem property');
  end;

  % Set up output location; always
  % create a new directory.
  if (~isfield(mSets.out, 'runspath')),    mSets.out.runspath    = repmat({'.'}, size(mSets.sigma)); end;
  if (~isfield(mSets.out, 'resultspath')), mSets.out.resultspath = repmat({'.'}, size(mSets.sigma)); end;
  if (~isfield(mSets.out, 'summarypath')), mSets.out.summarypath = '.'; end;
  if (~isfield(mSets.out, 'files')),       mSets.out.files       = {}; end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Make sure output paths exist
  if (~exist(mSets.out.summarypath, 'dir')), mkdir(mSets.out.summarypath); end;
  for si=1:length(mSets.sigma)
      if (~exist(mSets.out.runspath{si},    'dir')), mkdir(mSets.out.runspath{si}); end;
      if (~exist(mSets.out.resultspath{si}, 'dir')), mkdir(mSets.out.resultspath{si}); end;
  end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Save the plots
  if (exist('figs','var'))
    if (ismember(11, mSets.debug)), fprintf('Saving plots...'); end;
    [mSets.out] = de_SavePlots(mSets, figs);
    if (ismember(11, mSets.debug)), fprintf('done.\n'); end;
  end;

  % Save the stats
  if (exist('stats','var') && ~stats.cached)
    if (ismember(11, mSets.debug)), fprintf('Saving stats...'); end;
    [mSets.out] = de_SaveSummaryStats(mSets, stats);
    if (ismember(11, mSets.debug)), fprintf('done.\n'); end;
  end;

  % Save model & stats results
  if (exist('models','var') && exist('stats','var'))
    if (ismember(11, mSets.debug)), fprintf('Saving data...'); end;
    [mSets.out] = de_SaveData(mSets, models, stats);
    if (ismember(11, mSets.debug)), fprintf('done.\n'); end;
  end;

  success = 1;

