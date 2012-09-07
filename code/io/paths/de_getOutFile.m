function file = de_getOutFile(model, fileType, varargin)
%
%
%
  if (~exist('fullPath', 'var')), fullPath = 1; end;
  
  parts = mfe_split('.', fileType, 2);
  
  % Create filename from initial info
  switch (parts{1})
  
    % Shared parts
    case 'results'
      % Data info
      file = sprintf('%s-%s', model.data.stimSet, model.data.taskType);
      if (~isempty(model.data.opt))
        for i=1:length(model.data.opt), file = [file '-' model.data.opt{i}]; end;
      end;
      
      fullPath = 0;      
  
    case 'hash'
      % p info
      
      file = de_modelSummary(model, 'hash');
    
      fullPath = 0;
      
    % queryable
    case 'ac', 
      file = sprintf('%s-%d.ac', model.data.stimSet, model.ac.randState);  

    case 'p',  
      file = sprintf('%s-%s-ac%d-%d.p', de_getOutFile(model, 'results'), ...
                                        de_getOutFile(model, 'hash'), ...
                                        model.ac.randState, model.p.randState);
      
    case 'plot'
      figname = varargin{1};
      ext     = varargin{2};
      nRuns   = varargin{3};
      file = sprintf('%s_%s-%s-%s-r%d%s', ...
                     model.out.stem, ...
                     de_getOutFile(model, 'results'), ...
                     de_getOutFile(model, 'hash'), ...
                     figname, ...
                     nRuns, ...
                     ext);

    case 'stats'
      file = sprintf('%s-%s-%s.mat', ....
                     model.out.stem, ...
                     de_getOutFile(model, 'results'), ...
                     de_getOutFile(model, 'hash'));
      
    case {'data', 'summary'}
      ext     = varargin{1};
      nRuns   = varargin{2};
      file    = sprintf('%s_%s-%s-r%d%s', ...
                         model.out.stem, ...
                         de_getOutFile(model, 'results'), ...
                         de_getOutFile(model, 'hash'), ...
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
    
    file = fullfile(de_getOutPath(model, parts{1}), file);
  end;