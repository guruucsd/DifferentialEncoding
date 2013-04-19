function make_cache(dirs, cache_file, force_load);
%

  if ~exist('cache_file','var') || isempty(cache_file), cache_file = 'cache_file.mat'; end;
  if ~exist('force_load','var') || isempty(force_load), force_load = false; end;
  if ~exist('dirs','var') || isempty(dirs)
    global g_dir_cache
    if ~isempty(g_dir_cache)
      dirs = g_dir_cache;
    else
      dirs = dir();
      dirs = {dirs([dirs.isdir]).name};
      dirs = setdiff(dirs, {'.','..'});
    end;
  elseif ischar(dirs)
    dirs = {dirs};
  elseif ~iscell(dirs)
    error('dirs input var must be a string or a cell array of strings');
  end;

  % Clear the global cache
  global g_data_cache g_dir_cache;
  if force_load
    g_data_cache = {}; g_dir_cache = {};
  else
    [g_dir_cache,idx] = intersect(g_dir_cache, dirs);
    g_data_cache = g_data_cache(idx);
  end;
  dirs_toload = setdiff(g_dir_cache, dirs);


  % Force loading of relevant cache data
  for di=1:length(dirs_toload)
    fprintf('%s\n', dirs_toload{di}); 
    get_cache_data(dirs_toload{di}, cache_file); 
  end;

  save(cache_file, 'g_data_cache','g_dir_cache');

