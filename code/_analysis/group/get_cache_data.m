function [data,ts] = get_cache_data(dirnames, cache_file, force_load)
%function [data,ts] = get_cache_data(dirnames, cache_file, force_load)
%
% Returns summarized data from the given directory.  It can come from 3
%   places, searched in this order:
%
% 1. If ~force_load: The global cache (g_data_cache)
% 2. The specified cache file (cache_file)
% 3. From disk (searching the actual directory naem)
%
%
% If no cache file is specified, then step 2 is skipped.
%
%
% Dirnames: string, or cell array of strings.
% cache_file: 
%
%
% data: summarized data blob
% ts : info about timesteps

    global g_data_cache g_dir_cache;
    if isnumeric(g_dir_cache) % initialize kindly :)
      g_dir_cache={}; 
      g_data_cache={}; 
    end;
    
    % Default loading
    if ~exist('cache_file','var'), cache_file = ''; end;
    if ~exist('force_load','var'), force_load = false; end;
    if ischar(dirnames), dirnames = {dirnames}; end;
    
    % get just the directory name, eliminate any path
    dirnames = cellfun(@(d) guru_fileparts(d,'name'), dirnames, 'UniformOutput',false); 
    
    % Add extension to the cache file
    if ~isempty(cache_file) && ~strcmp('.mat', guru_fileparts(cache_file, 'ext'))
        cache_file = [cache_file '.mat'];
    end;

    
    % Get all data into global cache
    remain_dirs = dirnames;
    mi=1;
    while ~isempty(remain_dirs) && mi<=4
        switch mi
            
            case 1 % from global cache
                if ~force_load
                    [cur_found_dirs] = intersect(g_dir_cache, dirnames);
                end;
                
            case 2  % Look inside the cache file
                if ~exist(cache_file,'file'), error('Couldn''t find cache file: %s', cache_file); end;

                % Cache exists; either load it and merge.
                load_global_cache(cache_file, true);

                [cur_found_dirs] = intersect(g_dir_cache, dirnames);
                
                
            case 3 % Summarize directly from disk
                
                for di=1:length(remain_dirs)
                  % Get the approriate directory
                  dn = remain_dirs{di};
                  if ~exist(dn,'dir') && exist(fullfile(r_out_path('cache'), remain_dirs{di}),'dir')
                      dn = fullfile(r_out_path('cache'), remain_dirs{di});
                  end;

                  % Load the data
                  g_data_cache{end+1} = collect_data(dn);
                  g_dir_cache{end+1}  = remain_dirs{di}; 
                end;

        end;

        remain_dirs = setdiff(remain_dirs, cur_found_dirs);
        mi = mi+1;
    end;
    fprintf('Completed search with method = %d\n', mi-1);
    
    % Didn't find all
    if ~isempty(remain_dirs)
        error('Couldn''t find some data in global cache, cache file, nor at speicfied location: %s', cellfun(@(s) sprintf('%s\n',s), remain_dirs, 'UniformOutput', false));
    end;
    

    % Found all & loaded into global cache; extract & return!
    [~,idx] = ismember(dirnames, g_dir_cache);
    data = g_data_cache(idx);
    ts = g_data_cache{idx(1)}.ts;
