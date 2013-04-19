function [d,s,folders] = collect_data_looped(dirname, cache_file, prefix)
%

if ~exist('dirname','var'),    dirname    = 'runs'; end;
if ~exist('cache_file','var'), cache_file = ''; end; % no caching
if ~exist('prefix','var'),     prefix='tdlc'; end;

% Get all subfolders with given prefix
if isempty(dirname)
    paths = load_global_cache(cache_file, true);
    folders = cellfun(@(d) guru_fileparts(d,'name'), paths, 'UniformOutput', false);
else
    folders = dir(fullfile(dirname,[prefix '*']));
    folders = folders([folders.isdir]);
    folders = setdiff({folders.name}, {'.','..'});
end;

d = cell(length(folders),1);
s = cell(length(folders),1);

for foi=1:length(folders)
    % Get the data 
    curdir = fullfile(dirname, folders{foi});
    fprintf('Processing [%s]...', curdir);
    [d{foi},~,s{foi}] = get_cache_data(curdir, cache_file); % break the caching
%    d{foi} = d{foi}{1}; % strip off extra cell layer
%    s{foi} = s{foi}{1};
    
    fprintf('\n');
end;

