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
    dataFiles{end+1} = de_GetDataFile('christman_etal_1991', 'high_freq', 'recog', {'freqs', c_freqs});
    dataFiles{end+1} = de_GetDataFile('christman_etal_1991', 'low_freq',  'recog', {'freqs', c_freqs});
    
    %Kitterle
    dataFiles{end+1} = de_GetDataFile('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {'freqs', k_freqs});
    
    %Sergent: only need one of the tests; all use the same encodings
    dataFiles{end+1} = de_GetDataFile('sergent_1982', 'de', 'sergent', {});
    
    
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
        nTrainImages(i) = size(d{i}.train.X,2);
        nTestImages(i)  = size(d{i}.test.X,2);
    end;

    % Simple, expensive, hacky way to 
    %   normalize the total # of input images
    trainMult    = round(max(nTrainImages)./nTrainImages);
    testMult     = round(max(nTestImages)./nTestImages);
    
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
      