addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','_lib')));
evo_cache = fullfile(r_out_path('cache'),'evolution');

%% Preliminary tests
% Noise vs. no-noise
cogsci2013_figures(fullfile(evo_cache,'asymmetric_symmetric_nonoise.15'), fullfile(evo_cache,'asymmetric_symmetric_noise.15'), [0.3 0.4]);
[~,~,oh] = legend();
title('Learning Trajectory (asymmetric input, symmetric output)');
legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});

%
for fignum=[0.3 0.4]
    cogsci2013_figures(fullfile(evo_cache,'asymmetric_symmetric_nonoise.15'), fullfile(evo_cache,'symmetric_asymmetric_nonoise.15'), fignum);
    [~,~,oh] = legend();
    title('Learning Trajectory (no noise)');
    legend(oh, {'Intact (Asymmetric input, symmetric output)', 'Lesioned (Asymmetric input, symmetric output)', 'Intact (Symmetric input, asymmetric output)', 'Lesioned (Symmetric input, Asymmetric output)'});
end;

