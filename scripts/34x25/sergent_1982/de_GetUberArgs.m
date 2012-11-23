function [mSets] = de_SimulatorUber(obj, training_info, testing_info, opts, args)
%
% Run sergent task by training on all images

  if (~iscell(opt)),             opt      = {opt};     end;

  %%%%%%%%%%%%%%%%%
  % Setup
  %%%%%%%%%%%%%%%%%

  % Go from args to model settings
  dataFile = de_MakeDataset(expt, stimSet, taskType, opt);

  % Initialize model settings.
  %   Note: putting the dataFile first allows it to be overridden
  [settings] = de_Defaults(expt, stimSet, taskType, opt, 'dataFile', dataFile, varargin{:});
  [mSets]    = de_CreateModelSettings(settings{:});

  %%%%%%%%%%%%%%%%
  % Train autoencoders on some set of images
  %%%%%%%%%%%%%%%%%

  % Split up info into meaningful variables
  training_info_split = mfe_split('/', training_info);
  guru_assert(length(training_info_split)==2);
  training_expt     = training_info_split{1};
  training_imageset = training_info_split{2};

  % Remove args for perceptron
  non_p_argname_idx = find(guru_findstr(args(1:2:end),'p.')~=1);
  non_p_arg_idx = sort([2*non_p_argname_idx-1,2*non_p_argname_idx]);
  uber_args = args(non_p_arg_idx);

  %%%%%%%%%%%%%%%%
  % Pull out the path to the stored autoencoders
  %%%%%%%%%%%%%%%%%
  %dbstop in de_LoadOrTrain

  [trn.mSets, trn.models, trn.stats] = de_Simulator(training_expt, training_imageset, '', opts, uber_args{:});

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

 
