function [d,nts,noise,delay] = collect_data_looped(dirname, cache_file)

if ~exist('dirname','var'),    dirname    = 'runs'; end;
if ~exist('cache_file','var'), cache_file = ''; end; % no caching

folders = dir(fullfile(dirname,'tdlc*'));
folders = folders([folders.isdir]);

%ts = [15:5:50 75];
%noise = [1 0];
%delay = [2 10];

d = cell(length(folders),1);
nts = nan(size(d));
noise = nan(size(d));
delay = nan(size(d));

for foi=1:length(folders)
    folname = folders(foi).name;
    
    % Get the data 
    d{foi} = get_cache_data(fullfile(dirname, folname), cache_file); % break the caching
    d{foi} = d{foi}{1}; % strip off extra cell layer
    
    % Parse out particular properties
    [n] = sscanf(folders(foi).name,'tdlc2013_all-%dts-%dd');
    nts(foi) = n(1);
    delay(foi) = n(2);
    noise(foi) = (folders(foi).name(end) == 'n');

%    keyboard
%    for fi=1:length(files)
%        d{foi}{end+1} = get_cache_data(fullfile(dirname, folname, files(fi).name));
%        nts{foi}(end+1) = 1;
%        noise{foi}(end+1) = 1;
%        delay{foi}(end+1) = 1;
%    end;
end;

