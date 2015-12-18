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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [X, nInput, XLAB, DS] = stim2D(stimSet, taskType, opt);

  % Now index and apply options, including input weightings.
  [X, nInput]          = de_applyOptions(opt, X, nInput);

  % Nail down targets for each task

  unique_DS = unique(DS);  %datasets #1 and #2
  train_ds = unique_DS{1};       % this is train set; the other is test

  % Set up training set
  train_idx  = strcmp(train_ds, DS);
  train.X    = X(:,train_idx);
  train.XLAB = XLAB(train_idx);
  train.nInput = nInput;

  % Set up test set
  test_idx  = ~strcmp(train_ds, DS);
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
  function [X,nInput,XLAB,dataset]= stim2D(stimSet, taskType, opt)
  %
  %
  %
  %
    % Parse some options
    rseed = guru_getopt(opt, 'rseed', 1);
    image_reversals = guru_getopt(opt, 'image-reversals', false);

    % Query the images
    nimgs_in   = sscanf(stimSet, '%d');
    if ischar(nimgs_in), error('stimSet must be an integer'); end;
    nimgs_in = 2 * nimgs_in;  % train vs. test sets.

    indir = fullfile(de_GetOutPath([], 'datasets'), 'vanhateren');
    if (~exist(indir, 'dir'))
      error('van Hateren raw images do not exist at expected location: %s',...
            indir);
    end;

    files = dir(fullfile(indir, '*.iml'));
    if (length(files) < nimgs_in / 4)
      error('Expected %d van Hateren images; only found %d at %s.', ...
            nimgs_in / 4, length(files), indir);
    end;

    % Hard-coded info about van hateren images.
    nInput_In  = [1024 1536]; %y,x
    if guru_hasopt(opt, 'small'), nInput_Out = [34 25];
    elseif guru_hasopt(opt, 'medium'), nInput_Out = [68 50];
    else, nInput_Out = [135  100]; end;

    % Set up outputs
    nimgs_out_per_input = (1 + image_reversals);
    nimgs_out  = nimgs_out_per_input * nimgs_in; % train + test sets.
    X = zeros(prod(nInput_Out), nimgs_out);
    XLAB = cell(nimgs_out, 1);

    randn('seed',rseed), rand('seed', rseed)
    pi = 1;
    for ii=1:nimgs_in
        % Read each image
        img_idx = 1 + mod(ii - 1, floor(nimgs_in/4));  % try for 4 patches per
        img_filename = files(img_idx).name;
        imgnum = sscanf(img_filename, 'imk%d.iml');
        img_path = fullfile(indir, img_filename);

        img = mfe_readIML(img_path);

        % Select the middle portion of the image
        for tpi=1:5  % try up to 5 random patches
          rng = [1 1; nInput_In] + ceil([1 -1]' * nInput_Out/2);
          cpt = [randi(rng(:, 1)), randi(rng(:, 2))];
          patch    = getImagePatch(img, cpt, nInput_Out);
          [patch, is_good] = validate_and_normalize_patch(patch, opt);
          if is_good, break; end;
        end;

        if ~is_good
          imshow(img, [0 255]); title(img_path);
          warning('likely bad image; please delete %s', img_path);
          % continue  % sadly, can't continue...
        end;

        % Add the patch, even if it sucks :(
        X(:, pi)  = patch(:);
        XLAB{pi} = img_filename;
        pi = pi + 1;

        if image_reversals
          patch    = getImagePatch(img(:, end:-1:1), cpt, nInput_Out);
          patch = validate_and_normalize_patch(patch, opt);  % already tested, should pass
          X(:, pi)    = patch(:);
          XLAB{pi} = [img_filename '-rev'];
          pi = pi + 1;
      end;
    end;
    nInput = [nInput_Out(1) nInput_Out(2)];

    guru_assert(all(X(:) >= 0), 'no values outside [0 1]');
    guru_assert(all(X(:) <= 1), 'no values outside [0 1]');

    % Divide into training & test datasets
    dataset  = cell(nimgs_out, 1);
    dataset(1:floor(nimgs_out/2))     = {'1'};  % train
    dataset(floor(nimgs_out/2)+1:end) = {'2'};  % test


function patch = getImagePatch(img, cpt, outSz)
  pixrange = round([(cpt(1)  -outSz(1)/2)   (cpt(2)  -outSz(2)/2) ; ...
                    (cpt(1)-1+outSz(1)/2)   (cpt(2)-1+outSz(2)/2) ]);

  patch = img(pixrange(1,1):pixrange(2,1), pixrange(1,2):pixrange(2,2));
  guru_assert(~any(size(patch) - outSz));


function [normalized_patch, is_good] = validate_and_normalize_patch(img_patch, opt)
    % Parse some options
    min_variance = guru_getopt(opt, 'min-variance', 0.025);
    max_mean_diff = guru_getopt(opt, 'max-mean-diff', 0.45);  % difference from 0.5

    % Normalize to [0 1]
    normalized_patch = (img_patch - min(img_patch(:))) / (max(img_patch(:)) - min(img_patch(:)));
    is_good = ~any(isnan(normalized_patch(:)));

    img_std = std(normalized_patch(:));
    if img_std < min_variance
      is_good = false;
      fprintf('\t(skipping vanhateren patch; %.3f < min_variance)\n', img_std);
    end;

    img_mean_diff = abs(0.5 - mean(normalized_patch(:)));
    if img_mean_diff > max_mean_diff
      is_good = false;
      fprintf('\t(skipping vanhateren patch; %.3f > mean_diff)\n', img_mean_diff);
    end;

    if img_std < (1.5 * min_variance) && img_mean_diff > (max_mean_diff / 1.25)
      fprintf('\t(skipping vanhateren patch; bad mean,std combo)\n');
      is_good = false;
    end;
