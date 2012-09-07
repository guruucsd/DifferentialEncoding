function modelSettings = de_createModelSettings(varargin)
  
  % SET SOME GENERIC DEFAULTS
  
  %----------------
  % Run the DE
  %----------------
  
  modelSettings.runs    = 68;
%  modelSettings.deType  = 'de';
  
  modelSettings.debug    = [1];
%  modelSettings.ac.debug = [1];
%  modelSettings.p.debug  = [1];

  %----------------
  % DE Analysis Params
  %----------------

  % Analysis settings
  modelSettings.errorType   = 1; % unsigned error
  modelSettings.rej.types   = {'janet_full'};
  modelSettings.rej.width   = 4; % 2 std outside->rejected

  modelSettings.plots       = {'all'};
  modelSettings.stats       = {'all'};
  
  % Reporting results
  x = dbstack;
  modelSettings.out.datapath    = fullfile(de_getBaseDir(), 'runs');
  modelSettings.out.resultspath = fullfile(de_getBaseDir(), 'results');
  modelSettings.out.stem        = strrep(x(2).file, '.m', '');
  modelSettings.out.data        = {'info','mat'};
  modelSettings.out.plots       = {'png'};
  

  % set from input
  for i=1:2:nargin
    prop = varargin{i};
    val  = varargin{i+1};
    
    % Make sure cell-like properties are cells
    switch (prop)
      case {'plots','stats'}
        if (ischar(val))
          val = {val};
        end;
    end;
    
    % split up prop name by object and property
    parts = mfe_split('.',prop,2);
    if (length(parts)==1)
      obj = '';
    else
      obj = parts{1};
      prop =parts{2};
    end;
    
    % set on object
    if (strcmp(obj,''))% && isfield(modelSettings, prop))
      modelSettings.(prop) =  val;
    elseif (~strcmp(obj,''))% && isfield(modelSettings.(obj), prop))
      modelSettings.(obj).(prop) = val;
    %else
    %  error('Unknown setting: %s', varargin{i});
    end;
  end;
  
  % Load settings from input file
  modelSettings.data = load(modelSettings.dataFile);
  
  % Restamp some properties
  modelSettings.nInput = modelSettings.data.nInput;
  modelSettings.nOutput = modelSettings.nInput;

  
  % Output settings
  if (~isfield(modelSettings.out, 'datapath')),    modelSettings.out.datapath    = '.'; end;
  if (~isfield(modelSettings.out, 'resultspath')), modelSettings.out.resultspath = '.'; end;
  if (~isfield(modelSettings.out, 'files')),       modelSettings.out.files       = {}; end;

  stem                          = de_getDataFile(modelSettings.data.dim, ...
                                                 modelSettings.data.stimSet, ...
                                                 modelSettings.data.taskType, ...
                                                 modelSettings.data.opt, ...
                                                 sprintf('h%d_c%d', modelSettings.nHidden, modelSettings.nConns), ...
                                                 'dir');
  modelSettings.out.datapath    = (fullfile(modelSettings.out.datapath, stem));
  modelSettings.out.resultspath = (fullfile(modelSettings.out.resultspath, stem));
 