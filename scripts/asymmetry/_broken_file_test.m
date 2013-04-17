evo_cache = fullfile(r_out_path('cache'),'evolution');
h10_dir = fullfile(evo_cache, 'all_h5');

dirs = dir(fullfile(h10_dir,'*sy*_*sy*'));


for di=1:length(dirs)
    files = dir(fullfile(h10_dir, dirs(di).name, '*.mat'));
    if length(files)~=10, fprintf('\t%s: only %d files\n', dirs(di).name, length(files)); end;
        
    for fi=1:length(files)
        fpath = fullfile(h10_dir, dirs(di).name, files(fi).name);
        fprintf('Loading %s...', fpath);
        try
            load(fpath);
            fprintf('\n')
        catch
            fprintf(' **ERROR**\n');
        end;
    end;
end;