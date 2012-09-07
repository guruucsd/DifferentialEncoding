function [success,mSets] = de_DESaveAll(mSets, models, stats, figs)
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
  if (~isfield(mSets.out, 'datapath')),    mSets.out.datapath    = '.'; end;
  if (~isfield(mSets.out, 'resultspath')), mSets.out.resultspath = '.'; end;
  if (~isfield(mSets.out, 'files')),       mSets.out.files       = {}; end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % create the output paths
  if (~isfield(mSets.out, 'datapath'))
      error('Datapath should have  been set before calling me!');
  end;
  
%    stem                          = de_getDataFile(mSets.data.dim, ...
%                                                   mSets.data.stimSet, ...
%                                                   mSets.data.taskType, ...
%                                                   mSets.data.opt, ...
%                                                   sprintf('h%d_c%d', mSets.nHidden, mSets.nConns), ...
%                                                   'dir');
%    mSets.out.datapath    = (fullfile(mSets.out.datapath, stem));
%    mSets.out.resultspath = (fullfile(mSets.out.resultspath, stem));
    
  % Use old paths

  % Make sure output paths exist
  if (~exist(mSets.out.datapath,    'dir')), mkdir(mSets.out.datapath); end;
  if (~exist(mSets.out.resultspath, 'dir')), mkdir(mSets.out.resultspath); end;

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Save the plots
  if (exist('figs','var'))
    [mSets.out] = de_SavePlots(mSets, figs);
  end;
  
  % Save the stats
  if (exist('stats','var'))
    [mSets.out] = de_SaveStats(mSets, stats);
  end;
  
  % Save model & stats results
  if (exist('models','var') && exist('stats','var'))
    [mSets.out] = de_SaveData(mSets, models, stats);
  end;

  success = 1;

