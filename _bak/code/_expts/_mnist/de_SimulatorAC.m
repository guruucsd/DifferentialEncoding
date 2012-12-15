function [mSets,models,stats] = de_SimulatorAC(dim, stimSet, opt, varargin)
%
%
  tic;
  
  % Set up default args
%  if (~exist('stimSet', 'var')), stimSet  = 'mnist';   end;
  if (~exist('opt','var')),      opt      = {};        end;
  if (~iscell(opt)),             opt      = {opt};     end;
  
  % Go from args to model settings
  dataFile = de_MakeDataset(dim, 'AC', stimSet, '', opt);

  % Initialize model settings
  [mSets] = de_SettingsAC(stimSet, opt, 'dataFile', dataFile, varargin{:});

  % Run the code
  [models]      = de_TrainAllAC (mSets);
  [stats, figs] = de_AnalyzerAC(mSets, models); 
  [s,mSets]     = de_SaveAll(mSets, models, stats, figs);

  toc