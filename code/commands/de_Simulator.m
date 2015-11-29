function [mSets,models,stats] = de_Simulator(expt, stimSet, taskType, opt, varargin)
%
%
  tic;

  if (~iscell(opt)),             opt      = {opt};     end;

  %%%%%%%%%%%%%%%%%
  % Setup
  %%%%%%%%%%%%%%%%%

  % This function calls generic functions that are implemented / overwritten
  %   by particular experiments.  Add the path to the current experiment, so that
  %   it's functions are the ones run.
  de_SetupExptPaths(expt);

  % Go from args to model settings
  dataFile = de_MakeDataset(expt, stimSet, taskType, opt);

  % Initialize model settings.
  %   Note: putting the dataFile first allows it to be overridden
  [settings] = de_Defaults(expt, stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});
  [mSets]    = de_CreateModelSettings(settings{:});

  % Check if we even should be running

  %%%%%%%%%%%%%%%%%
  % Training
  %%%%%%%%%%%%%%%%%

  % Log the mapping between settings and integer to a text file,
  %   so we can easily look for this mapping later
  de_LogSettingsMap(mSets);


  % Train autoencoders
  [models]      = de_TrainAllAC          (mSets);

  % Train classifiers
  if isfield(mSets, 'p')
      [models]      = de_TrainAllP(mSets, models);
  end;

  %%%%%%%%%%%%%%%%%
  % Analysis
  %%%%%%%%%%%%%%%%%

  % Show model summary
  if (ismember(1,mSets.debug))
    fprintf(de_modelSummary(mSets));    % Show AC & P settings
  end;

  % Analyze the results
  [stats, figs] = de_Analyzer(mSets, models);

  % Save these off
  [s,mSets]     = de_SaveAll(mSets, models, stats, figs);

  toc
