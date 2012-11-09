function [train, test, aux] = de_StimCreate(stimSet, taskType, opt)
%
%
%
    if (~exist('stimSet','var') || isempty(stimSet)), stimSet = 'all'; end;
    if (exist(taskType) && ~isempty(taskType)), error('no tasks for uber dataset'); end;
    if (~iscell(opt)), opt = {opt}; end;

    %%%%%%%%%%%%%%%%%%%%
    % Collect options & settings for all studies
    %%%%%%%%%%%%%%%%%%%%

	sz         = 'large';
	if (guru_hasopt(opt, 'small')),  sz = 'small'; end;
	if (guru_hasopt(opt, 'medium')), sz = 'medium'; end;

	mSets.ac.minmax  = guru_getopt(opt, 'minmax', []);
%	mSets.ac.absmean = guru_getopt(opt, 'absmean', 1.26E-2);
	mSets.ac.debug   = [];
	mSets.ac.zscore = true;

	all_opt = {sz};

    %%%%%%%%%%%%%%%%%%%%
    % Collect input images for all studies
    %%%%%%%%%%%%%%%%%%%%

    datafiles = {}; % collect list of input files
    trains    = {};
    tests     = {};
    auxes     = {};

    %% Christman
    % Get options for christman study
    c_opts = all_opt;%{'thetas', guru_getopt(opt, 'c_thetas', pi/2), all_opt{:}};
    c_opts(end+[1:2]) = { 'cycles' guru_getopt(opt, 'c_cycles', [3 5 8 12 16]) };

%    if (guru_hasopt(opt, 'c_freqs')), c_opts(end+[1:2]) = { 'freqs'  guru_getopt(opt, 'c_freqs') };
%    else,                             c_opts(end+[1:2]) = { 'cycles' guru_getopt(opt, 'c_cycles', 2*2.^[0:4])  };
%    end;

    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('christman_etal_1991', 'all_freq', '', c_opts);


    %% Kitterle
    % Specify options EXPLICTLY
    k_opts = all_opt;
    k_opts(end+[1:2]) = { 'cycles' guru_getopt(opt, 'k_cycles', [5 12]) };

    % Create dataset
    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('kitterle_etal_1992', 'sf_mixed', '', k_opts);


    %% Sergent
    s_opts =  all_opt;

    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('sergent_1982', 'de', '', s_opts);


    %% SF
    sf_opts =  all_opt;

    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('sf', '', '', sf_opts);


    %% Young: grab all the face files at once (there are a bunch!); smallest size possible!
    y_opts =  all_opt;

    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('young_bion_1981', 'orig', '', y_opts);


    %% Van Hateren
    v_opts =  all_opt;

    [datafiles{end+1}, ...
     trains{end+1}, ...
     tests{end+1}, ...
     auxes{end+1}]         = de_MakeDataset('vanhateren', 'orig', '', v_opts);


    %%%%%%%%%%%%%%%%%%%%
    % Limit the TRAINING sets, based on the stimulus set
    %%%%%%%%%%%%%%%%%%%%

    switch (stimSet)
        case 'all' % keep all

        case 'natimg'
            for ii=length(datafiles):-1:1
                if (~guru_findstr(datafiles{ii},'vanhateren'))
                    trains    = trains([1:ii-1 ii+1:end]);
                    tests     = tests([1:ii-1 ii+1:end]);
                    auxes     = auxes([1:ii-1 ii+1:end]);
                    datafiles = datafiles([1:ii-1 ii+1:end]);
                end;
            end;

        case 'nosf' % remove spatial frequency
            for ii=length(datafiles):-1:1
                if (guru_findstr(datafiles{ii},'sf.'))
                    trains    = trains([1:ii-1 ii+1:end]);
                    tests     = tests([1:ii-1 ii+1:end]);
                    auxes     = auxes([1:ii-1 ii+1:end]);
                    datafiles = datafiles([1:ii-1 ii+1:end]);
                end;
            end;

        case 'simple'
            for ii=length(datafiles):-1:1
                if (~guru_findstr(datafiles{ii},'vanhateren') ...
                  && ~guru_findstr(datafiles{ii}, 'young') ...
                  && ~guru_findstr(datafiles{ii}, 'sf'))
                    trains    = trains([1:ii-1 ii+1:end]);
                    tests     = tests([1:ii-1 ii+1:end]);
                    auxes     = auxes([1:ii-1 ii+1:end]);
                    datafiles = datafiles([1:ii-1 ii+1:end]);
                end;
            end;

        case 'original'
            for ii=length(datafiles):-1:1
                %keyboard
                if (~guru_findstr(datafiles{ii},'young') ...
                 && ~guru_findstr(datafiles{ii},'christman') ...
                 && ~guru_findstr(datafiles{ii},'kitterle') ...
                 && ~guru_findstr(datafiles{ii},'sergent'))
                    trains    = trains([1:ii-1 ii+1:end]);
                    tests     = tests([1:ii-1 ii+1:end]);
                    auxes     = auxes([1:ii-1 ii+1:end]);
                    datafiles = datafiles([1:ii-1 ii+1:end]);
                end;
            end;


        otherwise, error('Unknown stim set: %s', stimSet);
    end;

    %%%%%%%%%%%%%%%%%%%%
    % Now, make an autoencoding dataset out of it
    %%%%%%%%%%%%%%%%%%%%

    % Load data
    d = cell(size(datafiles));
    nTrainImages = zeros(size(d));
    nTestImages  = zeros(size(d));
    for ii=1:length(datafiles)
        if (~exist(datafiles{ii}, 'file')), error('Must create data file %s', datafiles{ii}); end;

        % Store #s of images
        nTrainImages(ii) = size(trains{ii}.X,2);
        nTestImages(ii)  = size(tests{ii}.X,2);
    end;

    % Simple, expensive, hacky way to
    %   normalize the total # of input images
    %
    % NOTE: I've disabled this by setting every
    %   multiplier to ONE
    %
    trainMult    = ones(size( round(max(nTrainImages)./nTrainImages) ));
    testMult     = ones(size( round(max(nTestImages) ./nTestImages) ));

    nPixels      = size(trains{1}.X,1);
    train.X      = zeros(nPixels, sum(nTrainImages.*trainMult));
    train.XLAB   = cell(size(train.X,2),1);
    train.nInput = trains{1}.nInput;
    test.X       = zeros(nPixels, sum(nTestImages.*testMult));
    test.XLAB    = cell(size(test.X,2),1);
    test.nInput  = tests{1}.nInput;

    lastTrainImage = 0;
    lastTestImage  = 0;
    for ii=1:length(trains)
		trains{ii} = de_NormalizeDataset( trains{ii}, mSets );

        for jj=1:trainMult(ii)
            train.X(:,lastTrainImage+[1:size(trains{ii}.X,2)]) = trains{ii}.X;
            train.XLAB(lastTrainImage+[1:length(trains{ii}.XLAB)]) = trains{ii}.XLAB;
            lastTrainImage = lastTrainImage + size(trains{ii}.X,2);
        end;

		tests{ii} = de_NormalizeDataset( tests{ii}, mSets );

        for j=1:testMult(ii)
            test.X (:,lastTestImage +[1:size(tests{ii}.X, 2)]) = tests{ii}.X;
            test.XLAB (lastTestImage +[1:length(tests{ii}.XLAB) ]) = tests{ii}.XLAB;
            lastTestImage  = lastTestImage  + size(tests{ii}.X,2);
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%
    % Now, prep for return
    %%%%%%%%%%%%%%%%%%%%

%    aux.c_freqs   = c_freqs;
%    aux.k_freqs   = k_freqs;
    aux.datafiles = datafiles;