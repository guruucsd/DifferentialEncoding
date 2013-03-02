% No time dependence: control
cs2013_figures('nonoise_1', 'nonoise_10', [0.2])
[~,~,oh] = legend();
title('Learning Trajectory (control)');
legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});

% No time dependence: noise
cs2013_figures('noise_2_1', 'noise_10_1', [0.2])
title('Learning Trajectory (noise)');
[~,~,oh] = legend();
legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
