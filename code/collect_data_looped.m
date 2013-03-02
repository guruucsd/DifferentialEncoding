function [d,nts,noise,delay] = collect_data_looped(dirname, force_load)

if ~exist('dirname','var'),    dirname    = 'runs'; end;
if ~exist('force_load','var'), force_load = false; end;

folders = dir(fullfile(dirname,'tdlc*'));

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
    % $HACK: too lazy to properly strip off the 'data' part, which isnot
    % expected by get_cache_data
    d{foi} = get_cache_data(fullfile(dirname(6:end), folname), force_load);
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
