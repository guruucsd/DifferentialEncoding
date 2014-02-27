function [modelSettings] = de_SettingsHL(stimSet, taskType, opt, varargin)
% Default settings for 1D DE (on hierarchical stim)

  dim   = 1;
  aKeys = varargin(1:2:end);
  args = varargin;

  if (~ismember('mu',      aKeys)), args(end+1:end+2) = {'mu',      0}; end;
  if (~ismember('sigma',   aKeys)), args(end+1:end+2) = {'sigma',   [1.8 12]}; end;
  if (~ismember('deType',  aKeys)), args(end+1:end+2) = {'deType',  'de'}; end;
  if (~ismember('nHidden', aKeys)), args(end+1:end+2) = {'nHidden', 14}; end;
  if (~ismember('nConns',  aKeys)), args(end+1:end+2) = {'nConns',  7}; end;
  if (~ismember('runs',    aKeys)), args(end+1:end+2) = {'runs',    68}; end;
  if (~ismember('debug',   aKeys)), args(end+1:end+2) = {'debug',   1}; end;

  %----------------
  % DE Training Params
  %----------------

  % de
  if (~ismember('dataFile',  aKeys)), args(end+1:end+2) = {'dataFile', de_GetDataFile(dim, stimSet, taskType, opt); }; end;

  % autoencoder
  if (~ismember('ac.randState',     aKeys)), args(end+1:end+2) = {'ac.randState', dim}; end;
  if (~ismember('ac.AvgError',      aKeys)), args(end+1:end+2) = {'ac.AvgError',      0}; end;
  if (~ismember('ac.MaxIterations', aKeys)), args(end+1:end+2) = {'ac.MaxIterations', 1000}; end;
  if (~ismember('ac.Acc',           aKeys)), args(end+1:end+2) = {'ac.Acc',           1.005}; end;
  if (~ismember('ac.Dec',           aKeys)), args(end+1:end+2) = {'ac.Dec',           1.2}; end;
  if (~ismember('ac.EtaInit',       aKeys)), args(end+1:end+2) = {'ac.EtaInit',       0.1}; end;
  if (~ismember('ac.errorType',     aKeys)), args(end+1:end+2) = {'ac.errorType',     2}; end; % abs(ERR)
  if (~ismember('ac.XferFn',        aKeys)), args(end+1:end+2) = {'ac.XferFn',        3}; end;
  if (~ismember('ac.WeightInitType',aKeys)), args(end+1:end+2) = {'ac.WeightInitType','randn'}; end;
  if (~ismember('ac.debug',         aKeys)), args(end+1:end+2) = {'ac.debug',         1}; end;

  % perceptron
  if (~ismember('p.randState',     aKeys)), args(end+1:end+2) = {'p.randState', dim}; end;
  if (~ismember('p.AvgError',      aKeys)), args(end+1:end+2) = {'p.AvgError',      0}; end;
  if (~ismember('p.MaxIterations', aKeys)), args(end+1:end+2) = {'p.MaxIterations', 1500}; end;
  if (~ismember('p.Acc',           aKeys)), args(end+1:end+2) = {'p.Acc',           1.01}; end;
  if (~ismember('p.Dec',           aKeys)), args(end+1:end+2) = {'p.Dec',           1.2}; end;
  if (~ismember('p.EtaInit',       aKeys)), args(end+1:end+2) = {'p.EtaInit',       0.1}; end;
  if (~ismember('p.errorType',     aKeys)), args(end+1:end+2) = {'p.errorType',     2}; end;  % abs(ERR)
  if (~ismember('p.XferFn',        aKeys)), args(end+1:end+2) = {'p.XferFn',        3}; end;
  if (~ismember('p.WeightInitType',aKeys)), args(end+1:end+2) = {'p.WeightInitType','randn'}; end;
  if (~ismember('p.debug',         aKeys)), args(end+1:end+2) = {'p.debug',         1}; end;

  %----------------
  % DE Analysis Params
  %----------------

  % Analysis settings
  if (~ismember('errorType',aKeys)), args(end+1:end+2) = {'errorType', 2}; end;
  if (~ismember('rej.type',aKeys)),  args(end+1:end+2) = {'rej.types', {'maxerr', 'sample_std-normd'}}; end;
  if (~ismember('rej.width',aKeys)), args(end+1:end+2) = {'rej.width', [nan 3]}; end;

  if (~ismember('plots',aKeys)),     args(end+1:end+2) = {'plots', {'default'}}; end; %ls-bars', 'outliers'}}; end;
  if (~ismember('stats',aKeys)),     args(end+1:end+2) = {'stats', {'default'}}; end;

  % Reporting results
  if (~ismember('out.data',aKeys)),  args(end+1:end+2) = {'out.data',  {'cmd','info','mat'}}; end;
  if (~ismember('out.plots',aKeys)), args(end+1:end+2) = {'out.plots', {'png','fig'}}; end;
  if (~ismember('out.stem',aKeys)),  args(end+1:end+2) = {'out.stem', guru_callerAt(1)}; end;

  %----------------
  % Run this thing!
  %----------------

  [modelSettings]= de_createModelSettings(args{:});

