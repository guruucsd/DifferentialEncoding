function file = de_GetOutFile(model, fileType, varargin)
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
    case 'ac', 
      if (~isfield(model, 'uberpath'))
          file = sprintf('%s-%d.ac', model.data.stimSet, model.ac.randState);  
      
      else
          file = sprintf('all-%d.ac', model.ac.randState);
          %fprintf('[uber-file]');
      end;
      
    case 'p',  
      origString = [...%sprintf('RS=%f', model.p.randState), ... %this is marked on the file
                     sprintf('WT=%d', model.p.WeightInitType), ...
                     sprintf('TM=%d', model.p.TrainMode), ...
                     sprintf('AE=%f', model.p.AvgError), ...
                     sprintf('MI=%d', model.p.MaxIterations), ...
                     sprintf('ET=%d', model.p.errorType), ...
                     sprintf('XF=%d', model.p.XferFn), ...
                     sprintf('UB=%d', model.p.useBias), ...
                     sprintf('AC=%f', model.p.Acc), ...
                     sprintf('DC=%f', model.p.Dec), ...
                     sprintf('EI=%f', model.p.EtaInit), ...
                     sprintf('LB=%d', model.p.lambda), ...
                     sprintf('PW=%d', model.p.Pow), ...
                     sprintf('NH=%d', model.p.nHidden) ...
                    ];

      % Ridiculous internal directory name needs to be unique, but shortened.
      %   That's what hashes are for!
      hash = sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));
      
      file = sprintf('%s-%s-ac%d-%d.p', de_GetOutFile(model, 'results'), ...
                                        hash, ...
                                        model.ac.randState, ...
                                        model.p.randState);
      
    case 'plot'
      figname = varargin{1};
      ext     = varargin{2};
      nRuns   = varargin{3};
      file = sprintf('%s_%s-%s-%s-r%d%s', ...
                     model.out.stem, ...
                     de_GetOutFile(model, 'results'), ...
                     de_GetOutFile(model, 'hash'), ...
                     figname, ...
                     nRuns, ...
                     ext);

    case 'stats'
      file = sprintf('%s-%s-%s.mat', ....
                     model.out.stem, ...
                     de_GetOutFile(model, 'results'), ...
                     de_GetOutFile(model, 'hash'));
      
    case {'data', 'summary'}
      ext     = varargin{1};
      nRuns   = varargin{2};
      file    = sprintf('%s_%s-%s-r%d%s', ...
                         model.out.stem, ...
                         de_GetOutFile(model, 'results'), ...
                         de_GetOutFile(model, 'hash'), ...
                         nRuns, ...
                         ext);
    case 'settings-map'
      file = '_settings-map.txt';
      ext = 'txt';
      
    otherwise
      error('Unknown file type: %s', parts{1});
  end;
  
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