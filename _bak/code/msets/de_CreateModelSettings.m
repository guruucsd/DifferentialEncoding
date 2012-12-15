function mSets = de_CreateModelSettings(varargin)
  
  % SET SOME GENERIC DEFAULTS
  
  %----------------
  % Run the DE
  %----------------
  
  mSets.runs    = 68;
%  mSets.deType  = 'de';
  
  mSets.debug    = [1];
%  mSets.ac.debug = [1];
%  mSets.p.debug  = [1];

  %----------------
  % DE Analysis Params
  %----------------

  % Analysis settings
  mSets.errorType   = 1; % unsigned error
  mSets.rej.type    = {'janet_full'};
  mSets.rej.width   = 4; % 2 std outside->rejected

  mSets.plots       = {'all'};
  mSets.stats       = {'all'};
  
  % Reporting results
  x = dbstack;
  mSets.out.datapath    = fullfile(de_GetBaseDir(), 'runs');
  mSets.out.resultspath = fullfile(de_GetBaseDir(), 'results');
  mSets.out.stem        = strrep(x(2).file, '.m', '');
  mSets.out.data        = {'info','mat'};
  mSets.out.plots       = {'png'};
  

  % set from input
  mSets = guru_stampProps(mSets, varargin{:});

  % Load settings from input file
  if (~isfield(mSets, 'data')), mSets.data = load(mSets.dataFile); end;
  if (~isfield(mSets.data, 'taskType')), mSets.data.taskType = ''; end;
  
  % Restamp some properties
  if (~isfield(mSets, 'nInput')), mSets.nInput = mSets.data.nInput; end;
  mSets.nOutput = mSets.nInput;

  
  % Output settings
  if (~isfield(mSets.out, 'datapath')),    mSets.out.datapath    = '.'; end;
  if (~isfield(mSets.out, 'resultspath')), mSets.out.resultspath = '.'; end;
  if (~isfield(mSets.out, 'files')),       mSets.out.files       = {}; end;

  % Get the output directory name
  mSets.out.dirstem                          = de_GetDataFile(mSets.expt, ...
                                                              mSets.data.stimSet, ...
                                                              mSets.data.taskType, ...
                                                              mSets.data.opt, ...
                                                              sprintf('h%d_c%d', mSets.nHidden, mSets.nConns), ...
                                                              'dir', ... %output directory
                                                              '' ...     %specify relative (empty) base path
                                                             );
  mSets.out.datapath    = (fullfile(mSets.out.datapath, mSets.out.dirstem));
  mSets.out.resultspath = (fullfile(mSets.out.resultspath, mSets.out.dirstem));
 
  [mSets] = de_NormalizeDataset(mSets);
