addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

%% Time dependence: control

% % wrongly classified
for fi=cogsci2013_figures('cogsci2013/nonoise_2', 'cogsci2013/nonoise_10', [0.4 0.8])
    figure(fi);
    [~,~,oh] = legend();
    title('Learning Trajectory (control)');
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: noise

% % wrongly classified
for fi=cogsci2013_figures('cogsci2013/noise_2_1', 'cogsci2013/noise_10_1', [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (noise)');
    [~,~,oh] = legend();
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


%% Noise dependence: 2 time-steps
for fi=cogsci2013_figures('cogsci2013/nonoise_2', 'cogsci2013/noise_2_1', [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (delay=2 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


%% Noise dependence: 10 time-steps
for fi=cogsci2013_figures('cogsci2013/nonoise_10', 'cogsci2013/noise_10_1', [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


%% Noise dependence: 10 time-steps