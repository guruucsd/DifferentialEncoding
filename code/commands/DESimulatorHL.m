function [mSets,models,stats] = DESimulatorHL(dim, stimSet, taskType, opt, varargin)
%
%
  tic;
  
  % Set up default args
  %if (~exist('dim','var')),      dim      = 1;         end;
  if (~exist('stimSet', 'var')), stimSet  = 'de';      end;
  if (~exist('taskType','var')), taskType = 'sergent'; end;
  if (~exist('opt','var')),      opt      = {};        end;
  if (~iscell(opt)),             opt      = {opt};     end;
  
  % Go from args to model settings
  dataFile = fullfile(de_getBaseDir(), 'data', de_getDataFile(dim, stimSet, taskType, opt));

  % Initialize model settings
  switch (dim)
    case 1, [mSets] = de_DESettings_HL1D(stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});
    case 2, [mSets] = de_DESettings_HL2D(stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});
    
    otherwise, error('Unknown dimensionality: %d', dim);
  end;
  
  % Run the code
  [models]      = de_DETrainer   (mSets);
  [stats, figs] = de_DEAnalyzerHL(mSets, models); 

  [s,mSets]     = de_DESaveAll(mSets, models, stats, figs);

  %de_SaveStats(mSets, stats);
  %de_SavePlots(mSets, figs);
  %de_SaveData (mSets, models, stats);

  toc