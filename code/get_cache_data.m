function [data,ts] = get_cache_data(dirnames, force_load)
%
    global g_data_cache g_dir_cache;

    if ~exist('force_load', 'var'),force_load= false; end;

    if isnumeric(g_dir_cache), g_dir_cache={}; g_data_cache={}; end;
    if ischar(dirnames), dirnames = {dirnames}; end;

    % Purge old dataset from cache
    if force_load
        [~,idx] = ismember(dirnames, g_dir_cache);
        goodidx = setdiff(1:length(g_dir_cache),idx);
        g_data_cache = g_data_cache(goodidx);
        g_dir_cache  = g_dir_cache(goodidx);
    end;

    % Add missing dataset(s) to (giant) cache
    for di=1:length(dirnames)
        if ~ismember(dirnames{di}, g_dir_cache)
            g_data_cache{end+1} = collect_data(fullfile('data',dirnames{di}));
            g_dir_cache{end+1}  = dirnames{di}; end;
    end;

    % Select the current datasets
    [~,idx] = ismember(dirnames, g_dir_cache);

    data = g_data_cache(idx);
    ts = g_data_cache{idx(1)}.ts;
