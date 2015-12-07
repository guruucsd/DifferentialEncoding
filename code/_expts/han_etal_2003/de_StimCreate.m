function [train,test,aux] = de_StimCreate(stimSet, taskType, opt)
%

  if (~exist('opt','var')),      opt      = {};     end;

  % Get the hierarchical letters
  sergent_dir = fileparts(strrep(which(mfilename), 'han_etal_2003', 'sergent_1982'));
  addpath(sergent_dir);
  [train, test, aux] = de_StimCreate_HACK(guru_iff(strcmp(stimSet, 'cb'), 'de', stimSet), 'sergent', opt);
  rmpath(sergent_dir);

  % Expand size, to allow greater spacing.
  train = expand_size(train, 3);
  test = expand_size(test, 3);

  % Determine the border width
  border_width = guru_getopt(opt, 'border_width', 1);
  bg_color = guru_getopt(opt, 'bg_color', 0.5);

  % Now push them through the contrast balancing algorithm
  if strcmp(stimSet, 'cb')
      train = contrast_balance(train, border_width, bg_color);
      test = contrast_balance(test, border_width, bg_color);
  end;


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
