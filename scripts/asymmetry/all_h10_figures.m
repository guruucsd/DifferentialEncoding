if ~exist('cogsci2013_figures','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;

asymm_cache = fullfile(r_out_path('cache'),'asymmetry');
asymm_cache_file = fullfile(asymm_cache, 'all_10_cache_file.mat');
h10_dir = fullfile(asymm_cache, 'all_h10');

if exist(asymm_cache_file, 'file'), load(asymm_cache_file); end;


%% Preliminary tests

nccs = [2 0];
axon_noises = [0 2E-3];
datasets = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'};

%% Show the effect of noise within a single dataset
for d1=1:length(datasets)
    noise_dir   = fullfile(h10_dir,sprintf('%s_noise_n2',  datasets{d1}));
    nonoise_dir = fullfile(h10_dir,sprintf('%s_nonoise_n2',datasets{d1}));

    for fignum=[0.4]
        cogsci2013_figures(noise_dir, nonoise_dir, fignum, asymm_cache_file);
        [~,~,oh] = legend();
        title(sprintf('Effects of noise (within a dataset) (%s, ncc=2)', plot_escape(datasets{d1})));
    end;
end;

keyboard

%% Show the effect of #cc within a dataset
for d1=1:length(datasets)
    ncc0_dir = fullfile(h10_dir,sprintf('%s_nonoise_n0',datasets{d1}));
    ncc2_dir = fullfile(h10_dir,sprintf('%s_nonoise_n2',datasets{d1}));
      
    for fignum=[0.4]
        cogsci2013_figures(ncc0_dir, ncc2_dir, fignum);
        [~,~,oh] = legend();
        title(sprintf('Effect of #cc (within a dataset) (%s, nonoise)', plot_escape(datasets{d1})));
        legend(oh, {'Intact (ncc=0)', 'Lesioned (ncc=0)', 'Intact (ncc=2)', 'Lesioned (ncc=2)'});
    end;
end;


%% Compare different datasets, without noise
for d1=1:length(datasets)
    d1_dir = fullfile(h10_dir,sprintf('%s_nonoise_n2',datasets{d1}));
    for d2=d1+1:length(datasets)
        d2_dir = fullfile(h10_dir,sprintf('%s_nonoise_n2',datasets{d2}));
      
        for fignum=[0.4]
            cogsci2013_figures(d1_dir, d2_dir, fignum);
            [~,~,oh] = legend();
            title('Compare across datasets (no noise, ncc=2)');
            legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                        sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                        sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                        sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});
        end;
    end;
end;


%% Compare different datasets, with noise
for d1=1:length(datasets)
    d1_dir = fullfile(h10_dir,sprintf('%s_noise_n2',datasets{d1}));
    for d2=d1+1:length(datasets)
        d2_dir = fullfile(h10_dir,sprintf('%s_noise_n2',datasets{d2}));
      
        for fignum=[0.4]
            cogsci2013_figures(d1_dir, d2_dir, fignum);
            [~,~,oh] = legend();
            title('Compare across datasets (noise, ncc=2)');
            legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                        sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                        sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                        sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});
        end;
    end;
end;
