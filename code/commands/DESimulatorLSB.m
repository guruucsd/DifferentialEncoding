function [modelSettings,models,stats] = DESimulatorLSB(dim, stimSet, taskType, opt, varargin)
%
%
  tic;
  
  % Set up default args
  if (~exist('dim','var')),      dim      = 2;         end;
  if (~exist('stimSet', 'var')), stimSet  = 'lsb_orig';    end;
  if (~exist('taskType','var')), taskType = 'recog'; end;
  if (~exist('opt','var')),      opt      = {'small.1'}; end;
  if (~iscell(opt)),             opt      = {opt};     end;
  
  % Go from args to model settings
  dataFile = fullfile(de_getBaseDir(), 'data', de_getDataFile(dim, stimSet, taskType, opt));

  % Initialize model settings
  switch (dim)
    case 2, [modelSettings] = de_DESettings_LSB2D(stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});
    
    otherwise, error('Unknown dimensionality: %d', dim);
  end;
  
  % Run the code
  [models]      = de_DETrainer    (modelSettings);
  [stats, figs] = de_DEAnalyzerLSB(modelSettings, models); 
  
  de_SaveStats(modelSettings, stats);
  de_SavePlots(modelSettings, figs);
  
  toc