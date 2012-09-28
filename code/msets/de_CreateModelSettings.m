function mSets = de_CreateModelSettings(varargin)
  
  % set from input
  mSets = guru_stampProps(struct(), varargin{:});

  %
  %mSets.parallel = false;
  
  % Load settings from input file
  if (~isfield(mSets,      'data')),     mSets.data = load(mSets.dataFile); end;
  
  if (~isfield(mSets.data, 'taskType')), mSets.data.taskType = ''; end;
  if (~isfield(mSets.out, 'files')),     mSets.out.files       = {}; end;

  % Restamp some properties
  mSets.nInput  = mSets.data.train.nInput;
  mSets.nOutput = mSets.data.train.nInput;

  % Get the output directory name
  mSets.out.dirstem                          = de_GetDataFile(mSets.expt, ...
                                                              mSets.data.stimSet, ...
                                                              mSets.data.taskType, ...
                                                              mSets.data.opt, ...
                                                              sprintf('h%d_c%d', mSets.nHidden, mSets.nConns), ...
                                                              'dir', ... %output directory
                                                              '' ...     %specify relative (empty) base path
                                                             );

  % Append
  mSets.out.runspath    = fullfile(mSets.out.runspath, mSets.out.dirstem);
  mSets.out.resultspath = fullfile(mSets.out.resultspath, mSets.out.dirstem);
  
  mSets.data.train = de_NormalizeDataset(mSets.data.train, mSets);
  mSets.data.test.bias = mSets.data.train.bias; %total hack... but otherwise, bias is different between train & test! :(
  mSets.data.test  = de_NormalizeDataset(mSets.data.test,  mSets);
