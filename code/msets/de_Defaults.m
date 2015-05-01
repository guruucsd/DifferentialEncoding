function [args] = de_Defaults(expt, stimSet, taskType, opt, varargin)
% Takes in an array of strings, assumes they're a list of key-value pairs,
%   and fills in any key-value pairs that we expect but weren't specified.
%

  if (mod(nargin,2)==1), error('Odd # args; must be key-value pairs (even total #)'); end;
  aKeys = varargin(1:2:end);

  % Whatever we have, we output.
  args = varargin;


  % Take some args and expand them out.
  if ismember('spacing', aKeys)
      spacing = guru_getopt(args, 'spacing');
      aKeys{end+1} = 'sigma';
      args(end+1:end+2) = {'sigma', de_GetSigmasFromSpacing(spacing)};
      fprintf('Computed sigmas from spacing: [%s ]\n', sprintf(' %d', args{end}))
  end;

  % Whatever we don't have, add!


  % Run parameters
  if (~ismember('parallel',         aKeys)), args(end+1:end+2) = {'parallel', false}; end;

  %
  if (~ismember('expt',             aKeys)), args(end+1:end+2) = {'expt', expt}; end;

  if (~ismember('distn',            aKeys)), args(end+1:end+2) = {'distn',   'norme'}; end;
  if (~ismember('mu',               aKeys)), args(end+1:end+2) = {'mu',      0}; end;
  if (~ismember('sigma',            aKeys)), args(end+1:end+2) = {'sigma',   [4 18]}; end;
  if (~ismember('deType',           aKeys)), args(end+1:end+2) = {'deType',  'de'}; end;
  if (~ismember('nHidden',          aKeys)), args(end+1:end+2) = {'nHidden', 13}; end;
  if (~ismember('nConns',           aKeys)), args(end+1:end+2) = {'nConns',  100}; end;
  if (~ismember('runs',             aKeys)), args(end+1:end+2) = {'runs',    68}; end;
  if (~ismember('debug',            aKeys)), args(end+1:end+2) = {'debug',   1}; end;

  %----------------
  % DE Training Params
  %----------------

  % de
  if (~ismember('dataFile',         aKeys)), args(end+1:end+2) = {'dataFile', de_GetDataFile(expt, stimSet, taskType, opt); }; end;

  % autoencoder
  if (~ismember('ac.randState',     aKeys)), args(end+1:end+2) = {'ac.randState',     1}; end;
  if (~ismember('ac.AvgError',      aKeys)), args(end+1:end+2) = {'ac.AvgError',      0}; end;
  if (~ismember('ac.MaxIterations', aKeys)), args(end+1:end+2) = {'ac.MaxIterations', 350}; end;
  if (~ismember('ac.Acc',           aKeys)), args(end+1:end+2) = {'ac.Acc',           1.005}; end;
  if (~ismember('ac.Dec',           aKeys)), args(end+1:end+2) = {'ac.Dec',           1.2}; end;
  if (~ismember('ac.EtaInit',       aKeys)), args(end+1:end+2) = {'ac.EtaInit',       0.1}; end;
  if (~ismember('ac.errorType',     aKeys)), args(end+1:end+2) = {'ac.errorType',     2}; end;   % abs(ERR)
  if (~ismember('ac.XferFn',        aKeys)), args(end+1:end+2) = {'ac.XferFn',        3}; end;
  if (~ismember('ac.useBias',       aKeys)), args(end+1:end+2) = {'ac.useBias',       false}; end;
  if (~ismember('ac.WeightInitType',aKeys)), args(end+1:end+2) = {'ac.WeightInitType','rand-normd'}; end;
  if (~ismember('ac.WeightInitScale',aKeys)),args(end+1:end+2) = {'ac.WeightInitScale',0.25}; end;
  if (~ismember('ac.debug',         aKeys)), args(end+1:end+2) = {'ac.debug',         1}; end;
  if (~ismember('ac.continue',      aKeys)), args(end+1:end+2) = {'ac.continue',      0}; end;

  if (~ismember('ac.ts',            aKeys)), args(end+1:end+2) = {'ac.ts',            1}; end;
  if (~ismember('ac.lambda',        aKeys)), args(end+1:end+2) = {'ac.lambda',        0}; end;
  if (~ismember('ac.zscore',        aKeys)), args(end+1:end+2) = {'ac.zscore',        false}; end;

  % Analysis settings
  if (~ismember('ac.rej.props',     aKeys)), args(end+1:end+2) = {'ac.rej.props', {'err'}}; end;
  if (~ismember('ac.rej.type',      aKeys)), args(end+1:end+2) = {'ac.rej.type',  {'max'}}; end;
  if (~ismember('ac.rej.width',     aKeys)), args(end+1:end+2) = {'ac.rej.width', [nan]}; end;

  % perceptron
  if (any(guru_findstr(args, 'p.')==1))
      if (~ismember('p.randState',      aKeys)), args(end+1:end+2) = {'p.randState',     1}; end;
      if (~ismember('p.AvgError',       aKeys)), args(end+1:end+2) = {'p.AvgError',      0}; end;
      if (~ismember('p.MaxIterations',  aKeys)), args(end+1:end+2) = {'p.MaxIterations', 6000}; end;
      if (~ismember('p.Acc',            aKeys)), args(end+1:end+2) = {'p.Acc',           1.01}; end;
      if (~ismember('p.Dec',            aKeys)), args(end+1:end+2) = {'p.Dec',           1.2}; end;
      if (~ismember('p.EtaInit',        aKeys)), args(end+1:end+2) = {'p.EtaInit',       0.1}; end;
      if (~ismember('p.errorType',      aKeys)), args(end+1:end+2) = {'p.errorType',     2}; end;  % abs(ERR)
      if (~ismember('p.XferFn',         aKeys)), args(end+1:end+2) = {'p.XferFn',        3}; end;
      if (~ismember('p.useBias',        aKeys)), args(end+1:end+2) = {'p.useBias',       false}; end;
      if (~ismember('p.WeightInitType', aKeys)), args(end+1:end+2) = {'p.WeightInitType','rand-normd'}; end;
      if (~ismember('p.WeightInitScale',aKeys)), args(end+1:end+2) = {'p.WeightInitScale',0.10}; end;
      if (~ismember('p.debug',          aKeys)), args(end+1:end+2) = {'p.debug',         1}; end;
      if (~ismember('p.continue',       aKeys)), args(end+1:end+2) = {'p.continue',      0}; end;

      if (~ismember('p.nHidden',        aKeys)), args(end+1:end+2) = {'p.nHidden',       1}; end;
      if (~ismember('p.ts',             aKeys)), args(end+1:end+2) = {'p.ts',            1}; end;
      if (~ismember('p.lambda',         aKeys)), args(end+1:end+2) = {'p.lambda',        0}; end;
      if (~ismember('p.zscore',         aKeys)), args(end+1:end+2) = {'p.zscore',        false}; end;
      if (~ismember('p.ndupes',         aKeys)), args(end+1:end+2) = {'p.ndupes',        1}; end;

      if (~ismember('p.rej.props',      aKeys)), args(end+1:end+2) = {'p.rej.props',  {'err'}}; end;
      if (~ismember('p.rej.type',       aKeys)), args(end+1:end+2) = {'p.rej.type',   {'sample_std-normd'}}; end;
      if (~ismember('p.rej.width',      aKeys)), args(end+1:end+2) = {'p.rej.width',  [3]}; end;
  end;

  %----------------
  % DE Analysis Params
  %----------------

  if (~ismember('errorType',        aKeys)), args(end+1:end+2) = {'errorType', 2}; end;

  if (~ismember('plots',            aKeys)), args(end+1:end+2) = {'plots', {'default'}}; end; %ls-bars', 'outliers'}}; end;
  if (~ismember('stats',            aKeys)), args(end+1:end+2) = {'stats', {'default'}}; end;

  if (~ismember('out.runspath',     aKeys)), args(end+1:end+2) = {'out.runspath',    de_GetOutPath([], 'runs')}; end;
  if (~ismember('out.resultspath',  aKeys)), args(end+1:end+2) = {'out.resultspath', de_GetOutPath([], 'results')}; end;
  if (~ismember('out.data',         aKeys)), args(end+1:end+2) = {'out.data',        {'info','mat'}}; end;
  if (~ismember('out.plots',        aKeys)), args(end+1:end+2) = {'out.plots',       {'png','fig'}}; end;
  if (~ismember('out.stem',         aKeys)), args(end+1:end+2) = {'out.stem',        sprintf('%s[u%d,p%d]%d', guru_callerAt(1), ...
                                                                                                              any(strcmp(args(ischar(args)), 'uberpath')), ...
                                                                                                              any(strcmp(args(ischar(args)), 'uberpath')))}; end;
  if (~ismember('out.pub',          aKeys)), args(end+1:end+2) = {'out.pub',   0}; end;
  if (~ismember('out.titles',       aKeys)), args(end+1:end+2) = {'out.titles',   {'1', '2'}}; end;
