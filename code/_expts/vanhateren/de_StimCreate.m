function [train,test] = de_StimCreate(stimSet, taskType, opt)
%Input:
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%               orig     => original images
%               left     => left chimeric
%               right    => right chimeric
%               mixed    => mix of original, left, and right
%
%  taskType : a string specifying which OUTPUT task to train on
%               recog: face recognition task
%                        30 individuals in train & test sets
%                        4 different emotions/views in train & test sets
%               emot:  emotional recognition task (NYI)
%                        8 emotions in train & test sets
%                        15 different individuals in train & test sets
%
%  opt      : a vector of options; all listed will be applied
%
%OUTPUT: a data file with the following variables:
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but


  % implement this when it's got a task


  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'orig'; end;
  if (~exist('taskType','var')), taskType = 'recog'; end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  if (~exist('force','var'))     force    = 0;      end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [X, nInput, XLAB, DS] = stim2D(stimSet, taskType);

  % Now index and apply options, including input weightings.
  [X, nInput]          = de_applyOptions(opt, X, nInput);

  % Nail down targets for each task

  unique_DS = unique(DS);  %datasets #1 and #2
  ds = unique_DS{1};       % this is train set; the other is test

    % Set up training set
    train_idx  = find(strcmp(ds, DS));
    train.X    = X(:,train_idx);
    train.XLAB = XLAB(train_idx);
    train.nInput = nInput;

    % Set up test set
    test_idx  = find(~strcmp(ds, DS));
    test.X    = X(:,test_idx);
    test.XLAB = XLAB(test_idx);
    test.nInput = nInput;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, nInput_new] = de_applyOptions(opt, X, nInput)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

    X_new = X;
    nInput_new = nInput;

    i = 1;
    while (i<=length(opt))
      curopt = opt{i};
      if (~ischar(curopt)), i=i+1; continue; end;

      switch (curopt)

          case {'left','right','full'}
              switch (curopt)
                  case 'left'
                    X_new2 = reshape(X_new, [nInput_new, size(X_new,2)]);
                    X_new2 = X_new2(:,1:round(end/2),:);
%                    X_new2(:,round(end/2):end,:) = 0;
                  case 'right'
                    X_new2 = reshape(X_new, [nInput_new, size(X_new,2)]);
                    X_new2 = X_new2(:,round(end/2):end,:);
%                    X_new2(:,1:round(end/2),:) = 0;
              end;

              nInput_new = [nInput_new(1) round(nInput_new(2)/2)];
              X_new  = reshape(X_new2, [prod(nInput_new) size(X_new2,3)]);

          case {'chimeric-left','chimeric-right'}
              a = floor(nInput_new(2)/2);
              switch (curopt)
                  case 'chimeric-left'
                    X_new2 = reshape(X_new, [nInput_new, size(X_new,2)]);
                    X_new2(:,(end-a+1):end,:) = X_new2(:,1:a,:);
                  case 'chimeric-right'
                    X_new2 = reshape(X_new, [nInput_new, size(X_new,2)]);
                    X_new2(:,1:a,:) = X_new2(:,(end-a+1):end,:);
              end;
              X_new  = reshape(X_new2, [prod(nInput_new) size(X_new2,3)]);
      end;

      i = i+1;
    end;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,nInput,XLAB,dataset]= stim2D(stimSet, taskType)
  %
  %
  %
  %
    nimgs_in   = sscanf(stimSet, '%d');

    indir = fullfile(de_GetOutPath([], 'datasets'), 'vanhateren');
    if (~exist(indir, 'dir')), error('van Hateren raw images do not exist at expected location: %s', indir); end;

    fs       = dir(fullfile(indir, '*.iml'));
    if (length(fs)<nimgs_in), error('Expected %d van Hateren images; only found %d at %s.', nimgs_in, length(fs), indir); end;

    nInput_In  = [1024 1536]; %y,x
    if ischar(nimgs_in), error('stimSet must be an integer'); end;

    % Read each image
    nInput_Out = [135  100]; % y,x
    nimgs_out  = 2*nimgs_in;
    X = zeros(prod(nInput_Out), nimgs_out);

    imgnum = zeros(nimgs_in,1);
    for fi=1:nimgs_in
        img = mfe_readIML(fullfile(indir, fs(fi).name));
        imgnum(fi) = sscanf(fs(fi).name, 'imk%d.iml');

        % Select the middle portion of the image
        cpt      = round(nInput_In)/2;
        pixrange = round([(cpt(1)  -nInput_Out(1)/2)   (cpt(2)  -nInput_Out(2)) ; ...
                          (cpt(1)-1+nInput_Out(1)/2)   (cpt(2)-1+nInput_Out(2)) ]);

        img_left   = img(pixrange(1,1):pixrange(2,1), pixrange(1,2): 1:cpt(2)-1 );
        img_rt_rev = img(pixrange(1,1):pixrange(2,1), pixrange(2,2):-1:cpt(2) );

        X(:,2*fi-1)  = img_left(:);
        X(:,2*fi)    = img_rt_rev(:);

        X(:,2*fi-1) = (X(:,2*fi-1) - min(X(:,2*fi-1)))/(max(X(:,2*fi-1))-min(X(:,2*fi-1)));
        X(:,2*fi)   = (X(:,2*fi  ) - min(X(:,2*fi  )))/(max(X(:,2*fi  ))-min(X(:,2*fi  )));
    end;
    nInput = [nInput_Out(1) nInput_Out(2)];

    guru_assert(~any(X(:)<0), 'no values outside [0 1]');
    guru_assert(~any(X(:)>1), 'no values outside [0 1]');

    % Divide into datasets
    XLAB = cell(nimgs_out,1);
    XLAB(1:2:end-1) = guru_csprintf('left-%d',     num2cell(imgnum));
    XLAB(2:2:end)   = guru_csprintf('right_rev-%d',num2cell(imgnum));

    dataset  = cell(nimgs_out,1);
    dataset(1:floor(nimgs_out/2))     = {'1'};
    dataset(floor(nimgs_out/2)+1:end) = {'2'};


