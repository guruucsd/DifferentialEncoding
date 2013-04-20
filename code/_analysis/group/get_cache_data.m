function [data,ts,sets] = get_cache_data(dirs, cache_file, force_load)
%function [data,ts] = get_cache_data(irs, cache_file, force_load)
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
% dirs: string, or cell array of strings.
% cache_file: 
%
%
% data: summarized data blob
% ts : info about timesteps

    global g_data_cache g_dir_cache g_sets_cache;
    if isnumeric(g_dir_cache) % initialize kindly :)
      g_dir_cache={}; 
      g_data_cache={}; 
      g_sets_cache={};
    end;
    
    % Default loading
    if ~exist('cache_file','var'), cache_file = ''; end;
    if ~exist('force_load','var'), force_load = false; end;
    if ischar(dirs), dirs = {dirs}; end;
    
    % get just the directory name, eliminate any path
    dirnames = @(ds) cellfun(@(d) guru_fileparts(d,'name'), ds, 'UniformOutput',false); 
    
    % Add extension to the cache file
    if ~isempty(cache_file) && ~strcmp('.mat', guru_fileparts(cache_file, 'ext'))
    keyboard
        cache_file = [cache_file '.mat'];
    end;

    
    % Get all data into global cache
    remain_dirs = dirs;
    mi=1;
    while ~isempty(remain_dirs) && mi<=4
        switch mi
            
            case 1 % from global cache
                if force_load, mi = mi+1; continue; end;

                [~,idx] = intersect(dirnames(remain_dirs), g_dir_cache);
                cur_found_dirs = remain_dirs(idx);
                
            case 2  % Look inside the cache file
                if isempty(cache_file), mi=mi+1; continue; end;
                if ~exist(cache_file,'file'), error('Couldn''t find cache file: %s', cache_file); end;

                % Cache exists; either load it and merge.
                load_cache_file(cache_file);

                [~,idx] = intersect(dirnames(remain_dirs), g_dir_cache);
                cur_found_dirs = remain_dirs(idx);
                
            case 3 % Summarize directly from disk
                
                for di=1:length(remain_dirs)
                  % Get the approriate directory
                  d = remain_dirs{di};
                  if ~exist(d,'dir') && exist(fullfile(r_out_path('cache'), d),'dir')
                       d = fullfile(r_out_path('cache'), remain_dirs{di});
                  end;

                  % Load the data
                  [g_data_cache{end+1},g_sets_cache{end+1}] = collect_data(d);
                  [g_dir_cache(end+1)]                      = dirnames({d}); 
                end;
                
                [~,idx] = intersect(dirnames(remain_dirs), g_dir_cache);
                cur_found_dirs = remain_dirs(idx);
        end;

        remain_dirs = setdiff(remain_dirs, cur_found_dirs);
        mi = mi+1;
    end;
    fprintf('Completed search with method = %d\n', mi-1);
    
    % Didn't find all
    if ~isempty(remain_dirs)
        error('Couldn''t find some data in global cache, cache file, nor at speicfied location: %s', [remain_dirs{:}]);
    end;
    

    % Found all & loaded into global cache; extract & return!
    [~,idx] = ismember(dirnames(dirs), g_dir_cache);
    data = g_data_cache{idx};
    ts   = g_data_cache{idx(1)}.ts;
    sets = g_sets_cache{idx};
