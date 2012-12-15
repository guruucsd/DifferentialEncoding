function [mSets,models,stats] = de_Simulator(expt, stimSet, taskType, opt, varargin)
%
%
  tic;
  
  if (~iscell(opt)),             opt      = {opt};     end;
  
  % This function calls generic functions that are implemented / overwritten
  %   by particular experiments.  Add the path to the current experiment, so that
  %   it's functions are the ones run.
  expt_dir = de_GetExptDir(expt);
  if (~exist(expt_dir, 'dir')), error('Experiment does not exist at expected directory: %s', expt_dir); end;
  p = mfe_split(':', path());
  rmpath(p{guru_instr(p, fullfile('','_expts',''))});
  addpath(genpath(expt_dir));
  
  % Go from args to model settings
  dataFile = de_MakeDataset(expt, stimSet, taskType, opt);

  % Initialize model settings.
  %   Note: putting the dataFile first allows it to be overridden
  [mSets] = de_Settings(expt, stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});

  % Train autoencoders
  [models]      = de_TrainAllAC (mSets);

  % Train classifiers
  if (isfield(mSets, 'p'))
      [models]      = de_TrainAllP  (mSets, models);
  end;
  
  % Analyze the results
  [stats, figs] = de_Analyzer(mSets, models); 

  % Save these off
  [s,mSets]     = de_SaveAll(mSets, models, stats, figs);

  toc