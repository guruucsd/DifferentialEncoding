addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

cogsci_dir = fullfile(r_out_path('cache'), 'cogsci2013');
cache_file = fullfile(cogsci_dir, 'cogsci2013_cache.mat');

%% Time dependence: control

% % wrongly classified
for fi=cogsci2013_figures(fullfile(cogsci_dir, 'nonoise_2'), fullfile(cogsci_dir, 'nonoise_10'), [0.4 0.8])
    figure(fi);
    [~,~,oh] = legend();
    title('Learning Trajectory (control)');
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: noise

% % wrongly classified
for fi=cogsci2013_figures(fullfile(cogsci_dir, 'noise_2_1'), fullfile(cogsci_dir, 'noise_10_1'), [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (noise)');
    [~,~,oh] = legend();
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


%% Noise dependence: 2 time-steps
for fi=cogsci2013_figures(fullfile(cogsci_dir, 'nonoise_2'), fullfile(cogsci_dir, 'noise_2_1'), [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (delay=2 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


%% Noise dependence: 10 time-steps
for fi=cogsci2013_figures(fullfile(cogsci_dir, 'nonoise_10'), fullfile(cogsci_dir, 'noise_10_1'), [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


% Save off the cache file, for future fast access
if ~exist(cache_file, 'file')
    save_cache_data(cache_file);
end;