addpath(genpath('../code'));

dirs = dir()

for di=1:length(dirs)
    if ismember(dirs(di).name, {'.','..'}), continue; end; 
    if ~dirs(di).isdir, continue; end;
    fprintf('%s\n', dirs(di).name); 
    get_cache_data(dirs(di).name, true); 
end;
 
global g_data_cache g_dir_cache;

save('cache_file.mat', 'g_data_cache','g_dir_cache');

