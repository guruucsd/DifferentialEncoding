function [train,test,aux] = de_StimCreate(stimSet, taskType, opt)
%
%Input:
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%              de       => (default) equal weighting to LpSm LmSp LpSp LmSm
%              dff      => equal weighting to LpSm LmSp only
%              sergent  => equal weighting to "positive" and "negative",
%                         where "negative" == [LmSm] and "positive" is
%                         everything else
%  taskType : a string specifying which OUTPUT task to train on
%              dff      => 4 localist outputs, specifying whether one of two
%                          particular targets is at the local or global
%                          level (must be run with dff stimSet)
%              gary     => similar to dff task, but uses a non-localist output
%                          to express all 6 conditions in the sergent stimSet.
%              mtl      => 6 outputs, distributed as follows:
%                          (2) a target is present at the local/global level
%                          (2) a distracter is present at the local/global level
%                          (2) the sergent task below
%              sergent  => (default) single output: is there a target?
%  opt      : a vector of options; all listed will be applied
%               reza-ized => switch one distracter with one target (to replicate published DE)
%               swapped  => switch all targets with all distracters
%                           (note: a better test is to switch one target
%                            with one distracter)
%
%OUTPUT: a data file with the following variables:
%
%  LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID: indices representing the 8 different trial types
%
%  TALL:  index containing above 8 indices
%  TLBL : labels for all trial types, as indexed above
%
%  STIM : cell array containing each stimulus (usually 4: 2 targets, 2 distracters
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.TT   : 16 indices, one for each hierarchical stimulus, taken from TALL
%  train.ST   : vector of 16 strings, describing each unique hierarchical stimulus.
%               Tells the two stimuli and relationship that make up the hierarchical stimulus
%  train.TIDX : ?
%
%  train.Y    : target vectors for autoencoder (same as X)
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but

  if (~exist('opt','var')),      opt      = {};     end;

  % Get the hierarchical letters
  sergent_dir = fileparts(strrep(which(mfilename), 'lamb_yund_2000', 'sergent_1982'));
  addpath(sergent_dir);
  [train, test, aux] = de_StimCreate('de', 'sergent', opt);
  rmpath(sergent_dir);

  % Expand size, to allow greater spacing.
  train = expand_size(train, 3);
  test = expand_size(test, 3);

  % Determine the border width
  border_width = guru_getopt(opt, 'border_width', 1);
  bg_color = guru_getopt(opt, 'bg_color', 0.5);

  % Now push them through the contrast balancing algorithm
  train = contrast_balance(train, border_width, bg_color);
  test = contrast_balance(test, border_width, bg_color);


function dset = expand_size(dset, size_factor)
    nInput = dset.nInput * size_factor;
    n_imgs = size(dset.X, 2);
    X = zeros(prod(nInput), n_imgs);

    for ii = 1:n_imgs
        img = reshape(dset.X(:, ii), dset.nInput);
        img = imresize(img, size_factor, 'nearest');
        % Now shrink the size of the bars.
        shrank_img = zeros(size(img));
        for yi=3:nInput(1)-2
            for xi=2:nInput(2)-1
                img_patch = img(yi + [-1:1], xi + [-1:1]);
                if sum(img_patch(:)) == 9
                    shrank_img(yi, xi) = 1;
                end
            end;
        end;
        X(:, ii) = shrank_img(:);
    end;

    dset.nInput = nInput;
    dset.X = X;


function dset = contrast_balance(dset, border_width, bg_color)
    for ii=1:size(dset.X, 2)
      img = reshape(dset.X(:, ii), dset.nInput);
      img = guru_contrast_balance_image(img, border_width, bg_color);
      dset.X(:, ii) = img(:);
      guru_assert(length(unique(img(:))) == 3, ...
                  sprintf('Exactly three colors must be present; %d found.', ...
                          length(unique(img(:)))));
    end;
