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
%               small: 25% scale of original images (34x25)
%               medium:   50% scale of original images (68x50)
%               large: 100% scale of original images
%
%OUTPUT: a data file with the following variables:
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but


  % implement this when it's got a task


  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'orig'; end;
  if (~exist('taskType','var')), taskType = 'recog';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [X, nInput, SUBJ, EMO, DS] = stim2D(stimSet, 'train', taskType);

  % Now index and apply options, including input weightings.
  [X, nInput]          = de_applyOptions(opt, X, nInput);

  % Create labels
  XLAB = cell(size(X,2),1);
  for i=1:length(XLAB)
    XLAB{i} = sprintf('%s|%s', SUBJ{i},EMO{i});
  end;

  if (~isempty(taskType))
      % Nail down targets for each task
      [T]  = de_createTargets(taskType, X, SUBJ, EMO, DS);
      TLAB = cell(size(T,2),1);

      for ii=1:length(TLAB)
          TLAB{ii} = SUBJ{ii};
      end;
  end;

  unique_DS = unique(DS);  %datasets #1 and #2
  ds = unique_DS{1};       % this is train set; the other is test

    % Set up training set
    train_idx  = find(strcmp(ds, DS));
    train.X    = X(:,train_idx);
    train.SUBJ = SUBJ(train_idx);
    train.EMO  = EMO(train_idx);
    train.XLAB = XLAB(train_idx);
    train.nInput = nInput;
    if (~isempty(taskType))
        train.T    = T(:,train_idx);
        train.TLAB = TLAB(train_idx);
    end;

    % Set up test set
    test_idx  = find(~strcmp(ds, DS));
    test.X    = X(:,test_idx);
    test.SUBJ = SUBJ(test_idx);
    test.EMO  = EMO(test_idx);
    test.XLAB = XLAB(test_idx);
    test.nInput = nInput;
    if (~isempty(taskType))
        test.T    = T(:, test_idx);
        test.TLAB = TLAB(test_idx);
    end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, nInput_new] = de_applyOptions(opt, X, nInput)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

    X_new = X;
    nInput_new = nInput;

    ii = 1;
    while (ii<=length(opt))
      curopt = opt{ii};
      if (~ischar(curopt)), ii = ii + 1; continue; end;

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

      ii = ii+1;
    end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T]         = de_createTargets(taskType, X, SUBJ, EMO, DS)
  %
  % Take the input vector and taskType, and create a set of labels
  %

  % First, organize labels to see how many subjects and emotions there are
    nSubjects = length(unique(SUBJ));
    nEmotions = length(unique(EMO));

    if (size(X,2)~=nSubjects*nEmotions)
      error('Uneven distribution of subjects and emotions not expected.');
    end;

    switch (taskType)
      case 'recog'
        T = zeros(nSubjects, size(X,2));

        %subjectNum = 1;
        %for i=1:length(SUBJ)
          % We assume that
        %  if (i>1 && ~strcmp(SUBJ{i}, SUBJ{i-1}))
        %    subjectNum = subjectNum + 1;
        %  end;

        %  T(subjectNum, i) = 1;
        %end;

        % auto-label each subject with a number
        [s,d,idx] = unique(SUBJ);

        % that number turns into the index into T
        %   of what the subject is for that trial.
        for trial=1:size(T,2)
          T(idx(trial),trial) = 1;
        end;

      case 'emot'
        T = zeros(nEmotions, size(X,2));

        % auto-label each emotion with a number
        [e,d,idx] = unique(EMO);

        % that number turns into the index into T
        %   of what the emotion is for that trial.
        for trial=1:size(T,2)
          T(idx(trial),trial) = 1;
        end;
    end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,nInput,SUBJ,EMO,DS]= stim2D(set, tot, taskType)
  %
  %
  %
  %

    indir = fullfile(de_GetOutPath([], 'datasets'), 'CAFE');

    fs = dir(fullfile(indir, ['*_' set '.pgm']));

    % Need to produce original chimeric faces
    if (isempty(fs))
      rawdir = fullfile(indir, 'raw');
      if (~exist(rawdir, 'dir'))
        error('Couldn''t find raw CAFE files @ %s', rawdir);
      else
        makeChimeric(rawdir, indir, set);
        [X,nInput,SUBJ,EMO,DS] = stim2D(set,tot,taskType);
        return;
      end;
    end;

    % Import each vector, and make sure it's in the range [0 1]
    nInput = size(mfe_getpgmraw(fullfile(indir, fs(1).name)));
    X = zeros(prod(nInput), length(fs));
    TLBL = cell(size(fs));
    for fi=1:length(fs)
      f = fs(fi);
      TLBL{fi} = guru_fileparts(f.name, 'name');
      x = reshape(mfe_getpgmraw(fullfile(indir, f.name)), [prod(nInput) 1]);

      X(:,fi) = (x - min(x))/(max(x)-min(x));
    end;
    guru_assert(~any(X(:)<0), 'no values outside [0 1]');
    guru_assert(~any(X(:)>1), 'no values outside [0 1]');

    % Divide into datasets
    dataset  = cell(size(TLBL));

    for i=1:length(TLBL)
      parts   = mfe_split('_', TLBL{i});

      % Divide up into "datasets", which can be used later
      %   to choose between training and test sets.
      switch (taskType)
        case {'recog',''}
          switch (parts{2})
            % datset 1
            case {'m1','m2'},   dataset{i} = '1';
            case {'ht1','ht2'}, dataset{i} = '1';
            case {'s1','s2'},   dataset{i} = '1';
            case {'d1','d2'},   dataset{i} = '1';

            % dataset 2
            case {'a1','a2'},   dataset{i} = '2';
            case {'n1','n2', ...
                  'n3','n4', ...
                  'n5','n6'},   dataset{i} = '2';
            case {'h1','h2'},   dataset{i} = '2';
            case {'f1','f2'},   dataset{i} = '2';

            otherwise, error('Unknown emotion: %s', parts{2});
          end;

          % Hacks
          if (strcmp(parts{1},'040') && strcmp(parts{2}, 'n5'))
            dataset{i} = '1';
          end;

        case 'emot'
          error('emotion recognition task NYI');

        otherwise, error('Unknown task: ', taskType);
      end;
    end;

    % Create labels
    [SUBJ,EMO] = lbl2SubjDS(TLBL);
    DS = dataset;




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [subjects,emotions] = lbl2SubjDS(TLBL)
  %
  %
  %


    subjects = cell(size(TLBL));
    emotions = cell(size(TLBL));

    for i=1:length(TLBL)
      parts   = mfe_split('_', TLBL{i});

      subjects{i} = parts{1};

      switch (parts{2})
        % datset 1
        case {'m1','m2'},   emotions{i} = 'sad';
        case {'ht1','ht2'}, emotions{i} = 'happy (with teeth)';
        case {'s1','s2'},   emotions{i} = 'surprise';
        case {'d1','d2'},   emotions{i} = 'disgust';

        % dataset 2
        case {'a1','a2'},   emotions{i} = 'angry';
        case {'n1','n2', ...
              'n3','n4', ...
              'n5','n6'},   emotions{i} = 'neutral';
        case {'h1','h2'},   emotions{i} = 'happy';
        case {'f1','f2'},   emotions{i} = 'fear';

        otherwise, error('Unknown emotion: %s', parts{2});
      end;
    end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function makeChimeric(indir, outdir, side)
    warning('This is only for when you do not detect orig & chimeric pgm files.  They should be there!\n');

      % make all files chimeric, then save out
    fs = dir(fullfile(indir, '*.pgm'));
    fmt = 'pgm';

    for i=1:length(fs)
      f = fs(i);

      outfile = sprintf('%s_%s', guru_fileparts(f.name, 'name'), side);

      if (~strcmp(side, 'orig'))
        img = guru_makeChimeric( mfe_getpgmraw(fullfile(indir, f.name)), side );
      else
        img = mfe_getpgmraw(fullfile(indir, f.name));
      end;

      imwrite(img, fullfile(outdir, [outfile '.' fmt]));
    end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_visualizeData(outFile)
  %
  %

    load(outFile);
    nRows = 10;
    nCols = 12;

    for objName = {'train' 'test'}
      objName = objName{1};
      obj = eval(objName);

      figTitle = sprintf('Faces %s set; stimSet=%s, taskType=%s, opt=%s', ...
                         objName, stimSet, taskType, [opt{:}]);

      figure;
      set(findobj(gcf,'Type','text'),'FontSize',6) ;

      for i=1:size(obj.X,2)
        subplot(nRows,nCols,i);
        colormap gray;

        imagesc(reshape(obj.X(:,i), nInput));

        %
        set(gca, 'xtick',[],'ytick',[]);
        hold on;
        xlabel(guru_text2label(obj.XLAB));
      end;

      %
      hold on;
      mfe_suptitle(figTitle);

      %
      print(strrep(outFile, '.mat', sprintf('-%s.%s', objName, 'png')), '-dpng');
      close(gcf);
    end;

