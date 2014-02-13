function mSets = de_CreateModelSettings(varargin)

    % set from input
    mSets = guru_stampProps(struct(), varargin{:});
    nSigmas = length(mSets.sigma);

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
    base_runspath = mSets.out.runspath;
    base_resultspath = mSets.out.resultspath;

    mSets.out.dirstem = {};
    mSets.out.runspath = {};
    mSets.out.resultspath = {};
    mSets.out.summarypath = fullfile(base_resultspath, 'summary');

    if length(mSets.nHidden) == 1, mSets.nHidden = repmat(mSets.nHidden, size(mSets.sigma)); end;
    if length(mSets.nConns)  == 1, mSets.nConns  = repmat(mSets.nConns, size(mSets.sigma)); end;
    if length(mSets.hpl)     == 1, mSets.hpl     = repmat(mSets.hpl, size(mSets.sigma)); end;

    for si=1:nSigmas
        mSets.out.dirstem{si}  = de_GetDataFile( ...
            mSets.expt, ...
            mSets.data.stimSet, ...
            mSets.data.taskType, ...
            mSets.data.opt, ...
            sprintf('h%dx%d_c%d', mSets.nHidden(si)/mSets.hpl(si), mSets.hpl(si), mSets.nConns(si)), ...
            'dir', ... %output directory
            '' ...     %specify relative (empty) base path
        );

      % Append
        mSets.out.runspath{si}    = fullfile(base_runspath, mSets.out.dirstem{si});
        mSets.out.resultspath{si} = fullfile(base_resultspath, mSets.out.dirstem{si});
    end;

    mSets.data.train = de_NormalizeDataset(mSets.data.train, mSets);
    mSets.data.test.bias = mSets.data.train.bias; %total hack... but otherwise, bias is different between train & test! :(
    mSets.data.test  = de_NormalizeDataset(mSets.data.test,  mSets);
