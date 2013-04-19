function [data,ts] = get_cache_data(dirnames, cache_file)
%
    global g_data_cache g_dir_cache g_cache_file;
    
    if ~exist('guru_file_parts','file'), addpath(genpath('code')); end;
    if ~exist('cache_file','var'), 
        cache_file = 'cache_file.mat'; %local directory
        force_load = false;
    else
        force_load = isempty(cache_file);
    end;
    if ~strcmp('.mat', guru_fileparts(cache_file, 'ext'))
        cache_file = [cache_file '.mat'];
    end;
    
   % first time, didn't exist
    if exist(cache_file,'file')
        if ~strcmp(g_cache_file, cache_file)

          %tmp = load(cache_file);
          %g_data_cache = tmp.g_data_cache;
          cache = load(cache_file);

          % $TODO: merge old cache and current cache
          if isfield(cache,'g_dir_cache'), cache.dir_cache = cache.g_dir_cache; end;
          if isfield(cache,'g_data_cache'), cache.data_cache = cache.g_data_cache; end;
          
          if ~isempty(g_dir_cache)
              g_dir_cache = [g_dir_cache cache.dir_cache];
              g_data_cache = [g_data_cache cache.data_cache];
              g_cache_file = cache_file;
          else
              g_dir_cache = cache.dir_cache;
              g_data_cache = cache.data_cache;
              g_cache_file = cache_file;
          end;
          
        % could do something...
        else
            ;
        end;
        
    elseif isnumeric(g_dir_cache), 

      g_dir_cache={}; 
      g_data_cache={}; 
    end;
    
    if ischar(dirnames), dirnames = {dirnames}; end;

    % Purge old dataset from cache
    if force_load
        warning('Forcing to load all from scratch');
        [~,idx] = ismember(dirnames, g_dir_cache);
        goodidx = setdiff(1:length(g_dir_cache),idx);
        g_data_cache = g_data_cache(goodidx);
        g_dir_cache  = g_dir_cache(goodidx);
    end;

    % Add missing dataset(s) to (giant) cache
    for di=1:length(dirnames)
      dn = dirnames{di};
      if ~exist(dn,'file') && exist(fullfile(r_out_path('cache'), dirnames{di}),'file')
          dn = fullfile(r_out_path('cache'), dirnames{di});
      end;
      
      if ~ismember(dirnames{di}, g_dir_cache)
          g_data_cache{end+1} = collect_data(dn);
          g_dir_cache{end+1}  = dirnames{di}; 
      end;
    end;

    % Select the current datasets
    [~,idx] = ismember(dirnames, g_dir_cache);

    data = g_data_cache(idx);
    ts = g_data_cache{idx(1)}.ts;
