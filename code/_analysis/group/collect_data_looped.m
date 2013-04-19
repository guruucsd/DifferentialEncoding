function [d,nts,noise,delay,folders] = collect_data_looped(dirname, cache_file, prefix)
%

if ~exist('dirname','var'),    dirname    = 'runs'; end;
if ~exist('cache_file','var'), cache_file = ''; end; % no caching
if ~exist('prefix','var'), prefix='tdlc'; end;

% Get all subfolders with given prefix
if isempty(dirname)
    paths = load_global_cache(cache_file, true);
    folders = cellfun(@(d) guru_fileparts(d,'name'), paths, 'UniformOutput', false);
else
    folders = dir(fullfile(dirname,[prefix '*']));
    folders = folders([folders.isdir]);
    folders = {folders.name};
end;

d = cell(length(folders),1);
nts = nan(size(d));
noise = nan(size(d));
delay = nan(size(d));

for foi=1:length(folders)
    
    % Get the data 
    d{foi} = get_cache_data(fullfile(dirname, folders{foi}), cache_file); % break the caching
    d{foi} = d{foi}{1}; % strip off extra cell layer
    
    % Parse out particular properties
    [n] = sscanf(folders{foi},'tdlc2013_all-%dts-%dd');
    nts(foi) = n(1);
    delay(foi) = n(2);
    noise(foi) = (folders{foi}(end) == 'n');
end;

