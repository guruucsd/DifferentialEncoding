function ringo_summary(prefix)
%Plots from tdlc_all:
%
%for nonoise, delay=2 vs 10, recreate ringo plot
%for nonoise vs noise, delay = 10, recreate ringo plot

%for nonoise vs noise, delay = 10, do ringo plot across training (2x5 grid, rows=1:5,6:10, each 100 timesteps)


if ~exist('prefix','var'), prefix = 'tdlc2013_all'; end;

dirs_d2_nonoise  = dir(fullfile(r_out_path('cache'), [prefix '-*ts-2d']));
dirs_d10_nonoise = dir(fullfile(r_out_path('cache'), [prefix '-*ts-10d']));
dirs_d2_noise    = dir(fullfile(r_out_path('cache'), [prefix '-*ts-2dn']));
dirs_d10_noise   = dir(fullfile(r_out_path('cache'), [prefix '-*ts-10dn']));

[data,ts] = summarize_files(dirs_d2_nonoise, prefix);
keyboard

function [data,ts] = summarize_files(dirs, prefix)
    ts = guru_csscanf({dirs.name}, [prefix '-%dts']);
    data = cell(size(ts));
    for di=1:length(dirs)
        files = dir(fullfile(dirs(di).name, '*.mat'));
        for fi=1:numel(files)
            d = load(fullfile(dirs(di).name, files(fi).name));
            data{di} = [data{di} d.data];
        end;
    end;
    