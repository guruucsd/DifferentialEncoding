function [data_cache,dir_cache,sets_cache] = make_cache_file(dirnames, cache_file)
%function make_cache(dirname(s), cache_file)
%
% Take a set of dirnames, and save a cache file of their summary data to disk.
%
% dirname(s): names of folders with data to save
%   if not specified, then it uses the entire cache
%   if specified and the cache is empty, loads a cache from that location
%

  global g_dir_cache g_data_cache g_sets_cache

  if ~exist('cache_file','var') || isempty(cache_file), cache_file = 'cache_file.mat'; end;
  if ~exist('dirnames','var') || isempty(dirnames)
    dirnames = g_dir_cache;
  elseif ischar(dirnames)
    if ~isempty(g_dir_cache)
      dirnames = {dirnames};
    else
      [~,~,dirnames] = collect_data_looped( dirnames, '', '' );
    end;
  elseif ~iscell(dirnames)
    error('dirnames input var must be a string or a cell array of strings');
  % get just the directory name, eliminate any path
  else
    dirnames = cellfun(@(d) guru_fileparts(d,'name'), dirnames, 'UniformOutput',false); 
  end;

  % Clear the global cache
  [dir_cache,idx] = intersect(g_dir_cache, dirnames);
  if length(dir_cache) ~= length(dirnames)
      error('Could not find some requested directories: %s', ...
            cellfun(@(s) sprintf('%s\n',s), setdiff(dirnames, dir_cache), 'UniformOutput', false));
  end;
  data_cache      = g_data_cache(idx);
  sets_cache      = g_sets_cache(idx);

  save(cache_file, 'data_cache','dir_cache', 'sets_cache');

