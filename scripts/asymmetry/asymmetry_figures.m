function [fh] = asymmetry_figures(cache_file, plots)
%
%

    global g_sets_cache
    
    fh = [];
    
    % Plots
    if ~exist('cogsci2013_figures','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;
    if ~exist('guru_getOutPath',   'file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','..', '_lib'))); end;

    %
    if exist(cache_file, 'file'), load_cache_file(cache_file); end;


    %% Preliminary tests
    datasets = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'};
    ncc      = g_sets_cache{1}(1).ncc;
    
    %% Show the effect of noise within a single dataset
    for d1=1:length(datasets)
        noise_dir   = sprintf('%s_noise_n%d',  datasets{d1}, ncc);
        nonoise_dir = sprintf('%s_nonoise_n%d',datasets{d1}, ncc);

        for fignum=[0.4]
            cogsci2013_figures(nonoise_dir, noise_dir, fignum, cache_file);
            %[~,~,oh] = legend();
            title(sprintf('Effects of noise (%s, ncc=%d; %s)', plot_escape(datasets{d1}), ncc, get(get(gca,'Title'), 'String')));
        end;
    end;

    %keyboard
% 
%     %% Show the effect of #cc within a dataset
%     for d1=1:length(datasets)
%         ncc0_dir = sprintf('%s_nonoise_n0',datasets{d1});
%         ncc2_dir = sprintf('%s_nonoise_n2',datasets{d1});
%       
%         for fignum=[0.4]
%             cogsci2013_figures(ncc0_dir, ncc2_dir, fignum);
%             [~,~,oh] = legend();
%             title(sprintf('Effect of #cc (within a dataset) (%s, nonoise)', plot_escape(datasets{d1})));
%             legend(oh, {'Intact (ncc=0)', 'Lesioned (ncc=0)', 'Intact (ncc=2)', 'Lesioned (ncc=2)'});
%         end;
%     end;


    %% Compare different datasets, without noise
    for d1=1:length(datasets)
        d1_dir = sprintf('%s_nonoise_n%d',datasets{d1}, ncc);
        for d2=d1+1:length(datasets)
            d2_dir = sprintf('%s_nonoise_n%d',datasets{d2}, ncc);
      
            for fignum=[0.4]
                cogsci2013_figures(d1_dir, d2_dir, fignum);
                [~,~,oh] = legend();
                title(sprintf('Compare across datasets (no noise, ncc=%d)', ncc));
                legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                            sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});
            end;
        end;
    end;


    %% Compare different datasets, with noise
    for d1=1:length(datasets)
        d1_dir = sprintf('%s_noise_n%d',datasets{d1}, ncc);
        for d2=d1+1:length(datasets)
            d2_dir = sprintf('%s_noise_n%d',datasets{d2}, ncc);
      
            for fignum=[0.4]
                cogsci2013_figures(d1_dir, d2_dir, fignum);
                [~,~,oh] = legend();
                title(sprintf('Compare across datasets (noise, ncc=%d)',ncc));
                legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                            sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});
            end;
        end;
    end;
