function [outFile] = de_StimCreate(expt, stimSet, taskType, opt)

%    [mSets]   = guru_getopt(opt, 'modelSettings');         % Required option
    [c_freqs]  = guru_getopt(opt, 'c_freqs');         % Required option
    [k_freqs]  = guru_getopt(opt, 'k_freqs');         % Required option
    [nInput]   = guru_getopt(opt, 'nInput',     [31 13]);

    
    %%%%%%%%%%%%%%%%%%%%
    % Collect input images for all studies
    %%%%%%%%%%%%%%%%%%%%

    dataFiles = {};
    
    %Christman
    christman_path = fullfile(de_GetBaseDir, 'code', '_expts', 'christman_etal_1991/');
    addpath(christman_path);
    dataFiles{end+1} = de_StimCreate('christman_etal_1991', 'high_freq', 'recog',      {'freqs', c_freqs, 'nInput', nInput});
    dataFiles{end+1} = de_StimCreate('christman_etal_1991', 'low_freq',  'recog',      {'freqs', c_freqs, 'nInput', nInput});
    rmpath(christman_path);
    
    %Kitterle
    kitterle_path = fullfile(de_GetBaseDir, 'code', '_expts', 'kitterle_etal_1992/');
    addpath(kitterle_path);
    dataFiles{end+1} = de_StimCreate('kitterle_etal_1992',  'sf_mixed',  'recog_freq', {'freqs', k_freqs, 'nInput', nInput});
    rmpath(kitterle_path);
    
    %Sergent: only need one of the tests; all use the same encodings
    sergent_path = fullfile(de_GetBaseDir, 'code', '_expts', 'sergent_1982/');
    addpath(sergent_path);
    dataFiles{end+1} = de_StimCreate('sergent_1982',        'de',        'sergent',    {'nInput', nInput});
    rmpath(sergent_path);
    
    %Hsiao: grab all the face files at once (there are a bunch!); smallest size possible!
    if (prod(nInput) == 850)
		hsiao_path = fullfile(de_GetBaseDir, 'code', '_expts', 'hsiao_etal_2008/');
		addpath(hsiao_path);
        dataFiles{end+1} = de_StimCreate('hsiao_etal_2008', 'orig', 'recog', {'small'});
        rmpath(hsiao_path);
    end;
    
    
    %%%%%%%%%%%%%%%%%%%%
    % Now, make an autoencoding dataset out of it
    %%%%%%%%%%%%%%%%%%%%
    
    % Load data
    d = cell(size(dataFiles));
    nTrainImages = zeros(size(d));
    nTestImages  = zeros(size(d));
    for i=1:length(dataFiles)
        if (~exist(dataFiles{i}, 'file')), error('Must create data file %s', dataFiles{i}); end;
        d{i} = load(dataFiles{i});
        
        % Store #s of images
        nTrainImages(i) = size(d{i}.train.X,2);
        nTestImages(i)  = size(d{i}.test.X,2);
    end;

    % Simple, expensive, hacky way to 
    %   normalize the total # of input images
    %
    % NOTE: I've disabled this by setting every 
    %   multiplier to ONE
    %
    trainMult    = ones(size( round(max(nTrainImages)./nTrainImages) ));
    testMult     = ones(size( round(max(nTestImages) ./nTestImages) ));
    
    nPixels      = prod(nInput);
    train.X      = zeros(nPixels, sum(nTrainImages.*trainMult));
    train.XLAB   = cell(size(train.X,2),1);
    train.nInput = nInput;
    test.X       = zeros(nPixels, sum(nTestImages.*testMult));
    test.XLAB    = cell(size(test.X,2),1);
    test.nInput  = nInput;
    
    lastTrainImage = 0; 
    lastTestImage  = 0; 
    for i=1:length(d)
        for j=1:trainMult(i)
            train.X(:,lastTrainImage+[1:size(d{i}.train.X,2)]) = d{i}.train.X;
            train.XLAB(lastTrainImage+[1:length(d{i}.train.XLAB)]) = d{i}.train.XLAB;
            lastTrainImage = lastTrainImage + size(d{i}.train.X,2);
        end;
        
        for j=1:testMult(i)
            test.X (:,lastTestImage +[1:size(d{i}.test.X, 2)]) = d{i}.test.X;
            test.XLAB (lastTestImage +[1:length(d{i}.test.XLAB) ]) = d{i}.test.XLAB;
            lastTestImage  = lastTestImage  + size(d{i}.test.X,2);
        end;
    end;

    clear('d', 'nImages');
        
    %%%%%%%%%%%%%%%%%%%%
    % Now, save it!
    %%%%%%%%%%%%%%%%%%%%
    
    outFile        = de_GetDataFile(expt, stimSet, taskType, opt);
    
    if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
        mkdir(guru_fileparts(outFile,'pathstr'));
    end;
    
    save(outFile, 'train', 'test', 'stimSet', 'taskType', 'opt', ...
                'c_freqs', 'k_freqs', 'nInput');  
      