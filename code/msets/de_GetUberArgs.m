function [mSets] = de_GetUberArgs(obj, ac_info, p_info, opts, args)
%
% Run sergent task by training on all images

  if (~iscell(opts)),             opts      = {opts};     end;

  %%%%%%%%%%%%%%%%
  % Set up params
  %%%%%%%%%%%%%%%%%

  % Split up info into meaningful variables
  ac_info_split = mfe_split('/', ac_info);
  guru_assert(length(ac_info_split)==2);
  ac_expt     = ac_info_split{1};
  ac_imageset = ac_info_split{2};

  % Remove args for perceptron
  non_p_argname_idx = find(guru_findstr(args(1:2:end),'p.')~=1);
  non_p_arg_idx = sort([2*non_p_argname_idx-1,2*non_p_argname_idx]);
  ac_args = args(non_p_arg_idx);

  %%%%%%%%%%%%%%%%
  % Create model settings for ac
  %%%%%%%%%%%%%%%%%

  [ac_dataFile] = de_GetDataFile(ac_expt, ac_imageset, '', opts);
  [ac_settings] = de_Defaults(ac_expt, ac_imageset, '', opts, 'dataFile', ac_dataFile, ac_args{:});
  [ac_mSets]    = de_CreateModelSettings(ac_settings{:});

  if strcmp(obj,'ac')
      mSets = ac_mSets;
      return;
  end;


  %%%%%%%%%%%%%%%%
  % Get classifier model settings
  %%%%%%%%%%%%%%%%%

  guru_assert(length(ac_mSets.sigma)==1);
  dirs = de_GetOutPath(ac_mSets,'ac_p_base');

  p_info_split  = mfe_split('/', p_info);
  guru_assert(length(p_info_split) ==3);
  p_expt      = p_info_split{1};
  p_imageset  = p_info_split{2};
  p_task      = p_info_split{3};

  p_args = { args{:},'uberpath', dirs };

  [p_dataFile] = de_GetDataFile(p_expt, p_imageset, '', opts);
  [p_settings] = de_Defaults(p_expt, p_imageset, '', opts, 'dataFile', p_dataFile, p_args{:});
  [p_mSets]    = de_CreateModelSettings(p_settings{:});

  if strcmp(obj,'p')
      mSets = p_mSets;
      return;
  else
      error('Unknown object requested: %s', obj);
  end;
