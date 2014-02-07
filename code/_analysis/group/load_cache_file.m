function loaded_dirs = load_cache_file(cache_file, merge)

    global g_dir_cache g_data_cache g_sets_cache
 
    if ~exist('merge','var'), merge = true; end;
   
    cache = load(cache_file);

    % old saved cache used to have different variable names 
    if isfield(cache,'g_dir_cache'),  cache.dir_cache  = cache.g_dir_cache; end;
    if isfield(cache,'g_data_cache'), cache.data_cache = cache.g_data_cache; end;
    if isfield(cache,'g_sets_cache'), cache.sets_cache = cache.g_sets_cache; end; 
    if ~isfield(cache, 'sets_cache'), cache.sets_cache = cell(size(cache.data_cache)); end;

    dir_names = cellfun(@(d) guru_fileparts(d,'name'), cache.dir_cache, 'UniformOutput', false);
    
    %
    if ~merge || isempty(g_dir_cache)
        g_dir_cache = dir_names;
        g_data_cache = cache.data_cache;
        g_sets_cache = cache.sets_cache;
        
    else
        [~,addidx] = setdiff(g_dir_cache, cache.dir_cache);
        
        g_dir_cache  = [ dir_names g_dir_cache(addidx)];
        g_data_cache = [cache.data_cache g_data_cache(addidx)];
        g_sets_cache = [cache.sets_cache g_sets_cache(addidx)];
    end;

    loaded_dirs = cache.dir_cache;
