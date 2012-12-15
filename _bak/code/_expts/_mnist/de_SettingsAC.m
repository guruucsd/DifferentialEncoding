function [modelSettings] = de_SettingsAC(stimSet, opt, varargin)
% Sets default 2D 

  dim = 2;
  aKeys = varargin(1:2:end);
  args = varargin;
  
  if (~ismember('mu',      aKeys)), args(end+1:end+2) = {'mu',      0}; end;
  if (~ismember('sigma',   aKeys)), args(end+1:end+2) = {'sigma',   [4 18]}; end;
  if (~ismember('deType',  aKeys)), args(end+1:end+2) = {'deType',  'de'}; end;
  if (~ismember('nHidden', aKeys)), args(end+1:end+2) = {'nHidden', 13}; end;
  if (~ismember('nConns',  aKeys)), args(end+1:end+2) = {'nConns',  100}; end;
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
  if (~ismember('ac.MaxIterations', aKeys)), args(end+1:end+2) = {'ac.MaxIterations', 350}; end;
  if (~ismember('ac.Acc',           aKeys)), args(end+1:end+2) = {'ac.Acc',           1.005}; end;
  if (~ismember('ac.Dec',           aKeys)), args(end+1:end+2) = {'ac.Dec',           1.2}; end;
  if (~ismember('ac.EtaInit',       aKeys)), args(end+1:end+2) = {'ac.EtaInit',       0.1}; end;
  if (~ismember('ac.errorType',     aKeys)), args(end+1:end+2) = {'ac.errorType',     1}; end;   % abs(ERR)
  if (~ismember('ac.XferFn',        aKeys)), args(end+1:end+2) = {'ac.XferFn',        3}; end;
  if (~ismember('ac.WeightInitType',aKeys)), args(end+1:end+2) = {'ac.WeightInitType','rand-normd'}; end;
  if (~ismember('ac.debug',         aKeys)), args(end+1:end+2) = {'ac.debug',         1}; end;

  %----------------
  % DE Analysis Params
  %----------------
  
  % Analysis settings
  if (~ismember('errorType',aKeys)), args(end+1:end+2) = {'errorType', 1}; end;
  if (~ismember('rej.type',aKeys)),  args(end+1:end+2) = {'rej.type', {'maxerr', 'sample_std-normd'}}; end;
  if (~ismember('rej.width',aKeys)), args(end+1:end+2) = {'rej.width', [nan 3]}; end;

  if (~ismember('plots',aKeys)),     args(end+1:end+2) = {'plots', {'default'}}; end; %ls-bars', 'outliers'}}; end;
  if (~ismember('stats',aKeys)),     args(end+1:end+2) = {'stats', {'default'}}; end;
  
  % Reporting results
  if (~ismember('out.data',aKeys)),  args(end+1:end+2) = {'out.data', {'info','mat'}}; end;
  if (~ismember('out.plots',aKeys)), args(end+1:end+2) = {'out.plots', {'png','fig'}}; end;
  if (~ismember('out.stem',aKeys)),  args(end+1:end+2) = {'out.stem', guru_callerAt(1)}; end;
  if (~ismember('out.pub',aKeys)),   args(end+1:end+2) = {'out.pub', 0}; end;
  
  %----------------
  % Run this thing!
  %----------------
  
  [modelSettings]= de_CreateModelSettings(args{:});
