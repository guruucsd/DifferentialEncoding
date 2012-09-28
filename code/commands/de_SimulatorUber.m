function [trn, tst, dirs] = de_SimulatorUber(training_info, testing_info, opts, args)
%
% Run sergent task by training on all images

  tic;

  %%%%%%%%%%%%%%%%
  % Train autoencoders on some set of images
  %%%%%%%%%%%%%%%%%

  % Split up info into meaningful variables
  training_info_split = mfe_split('/', training_info);
  guru_assert(length(training_info_split)==2);
  training_expt     = training_info_split{1};
  training_imageset = training_info_split{2};

  non_p_args = {};
  ii = 1;
  while (ii <= length(args))
    if (ischar(args{ii}) && length(args{ii})>2 && strcmp(args{ii}(1:2),'p.'))
      ii = ii + 2;
    else
      non_p_args{end+1} = args{ii};
      ii = ii + 1;
    end;
  end;

  %%%%%%%%%%%%%%%%
  % Pull out the path to the stored autoencoders
  %%%%%%%%%%%%%%%%%
  %dbstop in de_LoadOrTrain

  [trn.mSets, trn.models, trn.stats] = de_Simulator(training_expt, training_imageset, '', opts, non_p_args{:})

  % Get the autoencoder directories
  ac = [trn.models(1,:).ac];
  dirs = cell(size(ac));
  for i=1:length(ac)
     dirs{i} = guru_fileparts(ac(i).fn, 'path');
  end;
  clear('ac');

  %dbstop in de_LoadOrTrain

  %%%%%%%%%%%%%%%%
  % Train classifiers on images run through the pre-trained autoencoders
  %%%%%%%%%%%%%%%%%

  testing_info_split  = mfe_split('/', testing_info);
  guru_assert(length(testing_info_split) ==3);
  testing_expt      = testing_info_split{1};
  testing_imageset  = testing_info_split{2};
  testing_task      = testing_info_split{3};

  p_args = { args{:},'uberpath', dirs };

  [tst.mSets, tst.models, tst.stats] = de_Simulator(testing_expt, testing_imageset, testing_task, opts, p_args{:});

  toc