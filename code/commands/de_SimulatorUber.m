function [trn, tst, dirs] = de_SimulatorUber(training_info, testing_info, opts, args)
%
% Run sergent task by training on all images

  %%%%%%%%%%%%%%%%
  % Train autoencoders on some set of images
  %%%%%%%%%%%%%%%%%

  % Split up info into meaningful variables
  training_info_split = mfe_split('/', training_info);
  guru_assert(length(training_info_split)==2, 'training info must have correct format: expt/stimset');
  training_expt     = training_info_split{1};
  training_imageset = training_info_split{2};

  % Remove args for perceptron
  non_p_argname_idx = find(guru_findstr(args(1:2:end),'p.')~=1);
  non_p_arg_idx = sort([2*non_p_argname_idx-1,2*non_p_argname_idx]);
  uber_args = args(non_p_arg_idx);

  [trn.mSets, trn.models, trn.stats] = de_Simulator(training_expt, training_imageset, '', opts, uber_args{:});

  % Get the autoencoder directories
  ac = [trn.models(1,:).ac];
  dirs = cell(size(ac));
  for i=1:length(ac)
     dirs{i} = guru_fileparts(ac(i).fn, 'path');
  end;
  clear('ac');

  %%%%%%%%%%%%%%%%
  % Train classifiers on images run through the pre-trained autoencoders
  %%%%%%%%%%%%%%%%%
  testing_info_split  = mfe_split('/', testing_info);
  guru_assert(length(testing_info_split) >=2, 'testing info must have correct format: expt/stimset[/tasktype]');
  testing_expt      = testing_info_split{1};
  testing_imageset  = testing_info_split{2};
  if length(testing_info_split)==2
      testing_task = '';
  else
      testing_task      = testing_info_split{3};
  end;

  p_args = { args{:},'uberpath', dirs };

  [tst.mSets, tst.models, tst.stats] = de_Simulator(testing_expt, testing_imageset, testing_task, opts, p_args{:});
