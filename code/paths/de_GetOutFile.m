function [file] = de_GetOutFile(model, fileType, varargin)
% This is a function that will construct the "proper" filename
%   for a given simulation, based on the simulation parameters.
%
% Most of the "work" is in determining the simulation's directory path,
%   which is a hash of the basic simulation settings.
%   From there, ac and p models, after training, are based on THEIR settings.
%
% Also important are summary files and others.
%
% Full list of fileType supported:
%   results - used for
%   hash    -

    if (~exist('fullPath', 'var')), fullPath = true; end;

    parts = mfe_split('.', fileType, 2);

    % Create filename from initial info
    switch (parts{1})

      % Shared parts


      case 'results'
          % Data info
          file = sprintf('%s-%s', model.data.stimSet, model.data.taskType);
          if (~isempty(model.data.opt))
              for i=1:length(model.data.opt)
                  if (ischar(model.data.opt{i}))
                      file = [file '-' model.data.opt{i}];
                  elseif (isnumeric(model.data.opt{i}))
                      file = [file '-' num2str(model.data.opt{i})];
                  elseif (islogical(model.data.opt{i}))
                      file = [file '-' num2str(model.data.opt{i})];
                  else
                      error('Cannot convert option to string, to create filename.');
                  end;
              end;
          end;

          fullPath = false; % why?

      case 'hash'
          % p info

          file = de_modelSummary(model, 'hash');

          fullPath = false;

    % queryable

    % Connections are stored to a directory based ONLY on its own properties,
    %   NOTHING about how it will be used after the pruned connections are established
    case 'conn'
      file = sprintf('%d.conn', model.ac.randState);

      fullPath = isempty(varargin);


    case 'ac',  % outpath already contains most of the complex properties.
      file = sprintf('%d.ac', model.ac.randState); %stimset is on the directory already

    case 'p',
      origString = [ sprintf('NI=%d', model.p.noise_input), ...
                     sprintf('WT=%d', model.p.WeightInitType), ...
                     sprintf('WS=%d', model.p.WeightInitScale), ...
                     sprintf('TM=%d', model.p.TrainMode), ...
                     sprintf('AE=%f', model.p.AvgError), ...
                     sprintf('MI=%d', model.p.MaxIterations), ...
                     sprintf('ET=%d', model.p.errorType), ...
                     sprintf('XF=[ %s]', sprintf('%d ',model.p.XferFn)), ...
                     sprintf('WL=[ %d %d ]', model.p.wlim(1), model.p.wlim(2)), ...
                     sprintf('UB=%d', model.p.useBias), ...
                     sprintf('AC=%f', model.p.Acc), ...
                     sprintf('DC=%f', model.p.Dec), ...
                     sprintf('EI=%f', model.p.EtaInit), ...
                     sprintf('LB=%d', model.p.lambda), ...
                     sprintf('PW=%d', model.p.Pow), ...
                     sprintf('NH=%d', model.p.nHidden), ...
                     sprintf('DO=%f', model.p.dropout), ...
                     sprintf('ND=%d', model.p.ndupes), ...
                     ... % why is this here? sprintf('LB=%d', model.ac.lambda) ...
                    ];

      % Ridiculous internal directory name needs to be unique, but shortened.
      %   That's what hashes are for!
      hash = sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));

      file = sprintf('%s-%s-%s-ac%d-%d.p', de_GetOutFile(model, 'results'), ...
                                        model.deType, ...
                                        hash, ...
                                        model.ac.randState, ...
                                        model.p.randState);

    case 'plot'
      figname = varargin{1};
      ext     = varargin{2};
      nRuns   = varargin{3};
      file = sprintf('%s_%s-%s-r%d-%s%s', ...
                     model.out.stem, ...
                     de_GetOutFile(model, 'hash'), ...
                     figname, ...
                     nRuns, ...
                     de_GetOutFile(model, 'results'), ...
                     ext);

    case {'stats'}
      nRuns   = model.runs;
      file = sprintf('%s-%s-r%d', ....
                     de_GetOutFile(model, 'results'), ...
                     de_GetOutFile(model, 'hash'), ...
                     nRuns);

    case {'data', 'summary'}
      ext     = varargin{1};
      nRuns   = varargin{2};
      file    = sprintf('%s_%s-r%d-%s%s', ...
                         model.out.stem, ...
                         de_GetOutFile(model, 'hash'), ...
                         nRuns, ...
                         de_GetOutFile(model, 'results'), ...
                         ext);
    case 'settings-map'
      file = '_settings-map.txt';
      ext = 'txt';

    otherwise
      error('Unknown file type: %s', parts{1});
  end;

  % Normalize any weirdness
  file = regexprep(file, '\.+', '.'); %normalize periods
  file = regexprep(file, '\s+', ' '); %normalize whitespace

  % Make into a full path
  if (fullPath)

    % Add sub-part
    if (~exist('ext','var'))
      if (length(parts) == 2)
        file = sprintf('%s.%s.mat', file, parts{2});
      else
        file = sprintf('%s.mat', file);
      end;
    end;

    file = fullfile(de_GetOutPath(model, parts{1}), file);
  end;
