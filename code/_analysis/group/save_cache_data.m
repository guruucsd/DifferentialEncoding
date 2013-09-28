function save_cache_data(cache_file, dir_cache, data_cache)

    global g_dir_cache g_data_cache;

    if ~exist('dir_cache',  'var'), dir_cache  = g_dir_cache;  end;
    if ~exist('data_cache', 'var'), data_cache = g_data_cache; end;

    save(cache_file, 'dir_cache', 'data_cache');

