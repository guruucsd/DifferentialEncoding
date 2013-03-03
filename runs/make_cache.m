function make_cache(dirs, cache_file);

  if ~exist('cache_file','var'), cache_file = 'cache_file.mat'; end;
  if ~exist('get_cache_data','file'), addpath(genpath('../code')); end;
  if ~exist('dirs','var')
    dirs = dir();
    dirs = {dirs([dirs.isdir]).name};
    dirs = setdiff(dirs, {'.','..'});
  elseif ischar(dirs)
    dirs = {dirs};
  elseif ~iscell(dirs)
    error('dirs input var must be a string or a cell array of strings');
  end;

  % Clear the global cache
  global g_data_cache g_dir_cache;
  g_data_cache = []; g_dir_cache = [];

  % Force loading of relevant cache data
  for di=1:length(dirs)
    fprintf('%s\n', dirs{di}); 
    get_cache_data(dirs{di}, true); 
  end;

  save(cache_file, 'g_data_cache','g_dir_cache');

