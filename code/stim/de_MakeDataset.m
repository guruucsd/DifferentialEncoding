function [dataFile, train, test, aux, timestamp] = de_MakeDataset(expt, stimSet, taskType, opt, show_figs, force)
% Given some selective parameters and a set of generic options, create a dataset, write it to disk, and return
%   the filename and the dataset.
%
% expt: selects an experiment, which has a set of stimuli (stimSet) and tasks (taskType) associated with it.
%
% opt: can be experiment-specific, or generic over all experiments (such as stimulus size, or filtering parameters)
%   * size: 'mini','small','medium','large': different sizes, in pixels
%   * filtering: 'lowpass','highpass','bandpass'
%   *

    if ~exist('opt','var'), opt = {}; end;
    if ~exist('show_figs', 'var'), show_figs = true; end;
    if ~exist('force', 'var'), force = false; end;

    if strcmp(expt, 'vanhateren')
        opt = {opt{1}};
    end
    % Setup path--each experiment implements a set of generic functions
    % (right, basically like a class, but through file & path manipulation--yuck).
    % So, set up the path to access this experiment's functions.
    p = path();
    de_SetupExptPaths(expt);

    % Get the file time of de_StimCreate
    fil = dir(which('de_StimCreate'));
    file_timestamp = fil.datenum;

    % Calc the "expected" datafile
    dataFile = de_GetDataFile(expt, stimSet, taskType, opt);

    % Invalidate cached data based on the timestamp.
    if exist(dataFile,'file') && ~force
        load(dataFile);
        if ~exist('timestamp', 'var') || timestamp ~= file_timestamp
            force = true;
        end;
    end;

    % If the file doesn't exist, then we have to create it!
    if ~exist(dataFile, 'file') || force
        fprintf('Creating dataset (force=%d).\n', force);
        % Get the base stimuli; not every function emits an aux, and some are
        %   forceful about what dataFile they use (probably legacy code)
        switch nargout('de_StimCreate')
            case 2
                [train,test] = de_StimCreate(stimSet, taskType, opt);
                aux = [];

            case 3
                [train,test,aux] = de_StimCreate(stimSet, taskType, opt);

            case 4
                [train,test,aux,dataFile] = de_StimCreate(stimSet, taskType, opt);

            otherwise
                error('de_StimCreate has the wrong number of output arguments!');
        end;

        % Make sure what comes out is the MVP (minimum viable product)
        all_required_props = {'X', 'XLAB', 'nInput'};
        if ~isempty(taskType), all_required_props{end+1} = 'T'; end;
        for prop_name=all_required_props
            guru_assert(isfield(train, prop_name{1}), ...
                        sprintf('Training set must have "%s" property defined.', prop_name{1}));
        end;

        % Stamp on parameters
        train.expt = expt; train.stimSet = stimSet;
        train.taskType = taskType;  train.opt = opt;
        test.expt  = expt; test.stimSet  = stimSet;
        test.taskType  = taskType; test.opt  = opt;

        % Apply missing (but expected) field
        if (~isfield(train, 'minmax')), train.minmax = guru_minmax(train.X(:)); end;
        if (~isfield(test, 'minmax')),  test.minmax  = guru_minmax(test.X(:)); end;

        if (~isfield(train, 'name')),   train.name   = 'train';  end;
        if (~isfield(test,  'name')),   test.name    = 'test';   end;

        % Apply any extra common options
        [train] = de_StimApplyOptions(train, opt);
        [test]  = de_StimApplyOptions(test, opt, train);

        % Visualize datasets
        if show_figs
            de_VisualizeDataset(train);
            de_VisualizeDataset(test);
        end;

        % Output everything (including images)
        if (~exist(guru_fileparts(dataFile,'pathstr'), 'dir'))
          guru_mkdir(guru_fileparts(dataFile,'pathstr'));
        end;

        timestamp = file_timestamp;  % alias it over to expected property name.
        save(dataFile, 'stimSet', 'taskType', 'opt', 'train', 'test', 'aux', 'timestamp');
    end;

    path(p); % Restore path

    % Variables should have been loaded or created; nothing left to do!
    guru_assert(exist('train', 'var'));
    guru_assert(exist('test', 'var'));


%%%%%%%%%%%%%%%%%
function dset = de_StimApplyOptions(dset, opts, dset_to_match)
%
% Applies a set of generic options to the given dataset.
%
% dset_to_match is for any options that can take parameters from another dataset
%   (so that they use the same information)
%
    dset = de_StimApplyFiltering(dset, opts);

    dset = de_StimApplyTransform(dset, opts);

    dset = de_StimApplyResizing(dset, opts);

    if (exist('dset_to_match','var'))
        dset = de_StimApplyWhitening(dset, opts, dset_to_match);
    else
        dset = de_StimApplyWhitening(dset, opts);
    end;


function dset = de_StimApplyTransform(dset, opts)

    % Convert all images into polar coordinates, like Plaut & Behrmann 2011
    if guru_hasopt(opts, 'img2pol')
        dset.X = guru_img2pol(dset.X, guru_getopt(opts, 'location', 'CVF'));
    end;

    if guru_hasopt(opts, 'contrast')
      clevel = guru_getopt(opts, 'contrast', []);
      error('Contrast level option NYI');

      % But we want the target data to be the original image!
      dset.Y = dset.X;

      % First apply the image change
      % Taken from http://maksim.sorokin.dk/it/2010/11/08/brightness-and-contrast-in-matlab/
      for ii=1:size(dset.X,2)
          img = reshape(dset.X(:,ii), dset.nInput);
          img_range = [min(img(:)) max(img(:))];
          sigmoid   = @(x) 1./(1+exp(-x));
          switch clevel
            case 'low',
                mir = mean(img_range);
                caimg = imadjust(img, img_range, [img_range(1)+mir/2 img_range(2)-mir/2], 0.5);
            case 'high'
                simg = sigmoid(img);
                caimg = imadjust(simg, [min(simg(:)) max(simg(:))], [0 1]);
            otherwise, error('Unknown contrast level: %s', clevel);
          end;
          caimg = caimg - mean(caimg(:)) + mean(img(:));
          caimg(caimg>img_range(2)) = img_range(2);
          caimg(caimg<img_range(1)) = img_range(1);

          dset.X(:,ii) = caimg(:);
      end;

    end;


function dset = de_StimApplyResizing(dset, opts)
%

    if     (guru_hasopt(opts, 'mini')),   tgtInput = [27 20];
    elseif (guru_hasopt(opts, 'small')),  tgtInput = [34 25];
    elseif (guru_hasopt(opts, 'medium')), tgtInput = [68 50];
    elseif (guru_hasopt(opts, 'standard')), tgtInput = [102 75];
    elseif (guru_hasopt(opts, 'large')),  tgtInput = [135 100];
    elseif (guru_hasopt(opts, 'nInput')), tgtInput = guru_getopt(opts, 'nInput');
    else, return;
    end;

    % Must resize
    if (any(dset.nInput(1:2)-tgtInput))

        yscale = tgtInput(1)/dset.nInput(1);
        xscale = tgtInput(2)/dset.nInput(2);

        is_binary = length(unique(dset.X(:))) == 2;
        interp_method = guru_iff(is_binary, 'nearest', 'bicubic');

        % Rescale image
        X = zeros([tgtInput size(dset.X,2)]);
        for ii=1:size(dset.X,2)

            % Scale based on the dimension we must maximally scale
            tmp    = imresize(reshape(dset.X(:,ii), dset.nInput), ...
                              min(xscale, yscale), interp_method);

            % Add padding
            npad = max(tgtInput - size(tmp));
            npad1 = round(npad/2);
            npad2 = npad - npad1;

            if (xscale>yscale)
                X(:,npad1+1:end-npad2,ii) = tmp;
            else
                X(npad1+1:end-npad2,:,ii) = tmp;
            end;
        end;

        dset.X      = reshape(X, [prod(tgtInput) size(X,3)]);
        dset.nInput = tgtInput;
    end;


%%%%%%%%%%%%%%%%%
function dset = de_StimApplyFiltering(dset, opts)

    % Blurring
    blurring = guru_getopt(opts, 'blurring', 0);
    if (blurring > 0)
        for ii=1:size(dset.X,2)
           dset.X(:,ii) = reshape( imfilter(reshape(dset.X(:,ii), dset.nInput(1:2)), ...
                                            fspecial('gaussian', 3*blurring*[1 1], blurring), ...
                                            'same'), ...
                                   [size(dset.X,1) 1] );

        end;
    end;

    % Low-pass filter
    lowpass_filter = guru_getopt(opts, 'lowpass', NaN );
    if (~isnan(lowpass_filter))
        guru_assert(length(lowpass_filter), 'Lowpass filter should have 1 parameter');
        num_images = size(dset.X, 2);
        filt_images = guru_filterImages(reshape(dset.X', [num_images dset.nInput]), 'lowpass', lowpass_filter);
        dset.X = reshape(filt_images,[num_images prod(dset.nInput)])';
    end;

    % Band-pass filter
    bandpass_filter = guru_getopt(opts, 'bandpass', NaN);
    if (~isnan(bandpass_filter))
        guru_assert(length(bandpass_filter), 'Bandpass filter should have 2 parameters');
        num_images = size(dset.X, 2);
        filt_images = guru_filterImages(reshape(dset.X', [num_images dset.nInput]), 'bandpass', bandpass_filter);
        dset.X = reshape(filt_images,[num_images prod(dset.nInput)])';
    end;

    % High-pass filter
    highpass_filter = guru_getopt(opts, 'highpass', NaN);
    if (~isnan(highpass_filter))
        guru_assert(length(highpass_filter), 'Highpass filter should have 1 parameter');
        num_images = size(dset.X, 2);
        filt_images = guru_filterImages(reshape(dset.X', [num_images dset.nInput]), 'highpass', highpass_filter);
        dset.X = reshape(filt_images,[num_images prod(dset.nInput)])';
    end;

    % Noise filter
    noise_filter = guru_getopt(opts, 'noise', NaN);
    if (~isnan(noise_filter))
        guru_assert(length(noise_filter), 'Noise filter should have 1 parameter');
        dset.X = dset.X + noise_filter * diff(dset.minmax) * randn(size(dset.X));%reshape(filt_images,[num_images prod(dset.nInput)])';
        dset.X = max(dset.minmax(1), min(dset.minmax(2), dset.X));
    end;


%%%%%%%%%%%%%%%%%
function dset = de_StimApplyWhitening(dset, opts, dset_to_match)

    % Whitening
    whiten = guru_getopt(opts, 'dnw', false);
    if (islogical(whiten) && whiten)
        if (exist('dset_to_match','var') && isfield(dset_to_match,'axes')),
            [dset.X, dset.axes] = guru_dnw( dset.X, dset_to_match.axes );
        else,
            [dset.X, dset.axes] = guru_dnw( dset.X );
        end;

    % The axes were passed in directly
    elseif isnumeric(whiten)
        [dset.X, dset.axes] = guru_dnw( dset.X, whiten );

    end;

    % specifies the dataset to whiten with
    [xwhiten,~,idx] = guru_getopt(opts, 'xdnw', []);
    if (~isempty(xwhiten))

        if (exist('dset_to_match','var') && isfield(dset_to_match,'axes'))
            dset.X    = guru_dnw( dset.X, dset.axes );
        else
            otheropts = {opts{1:idx-1} opts{idx+2:end}};
            [~,train] = de_MakeDataset(xwhiten, '', '', {otheropts{:} 'dnw' true});
            dset.axes = train.axes;
        end;
    end;
