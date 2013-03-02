function cs2013_figures(nonoise_dir, noise_dir, plots)

global clean_data noise_data;

%clean_data = []; noise_data = [];

if ~exist('nonoise_dir', 'var'), nonoise_dir = 'cs2013_nonoise'; else, clean_data = []; end;
if ~exist('noise_dir', 'var'),   noise_dir   = 'cs2013_noise';   else, noise_data = []; end;
if ~exist('plots','var'),        plots       = [ 0.25 ]; end;

if isempty(clean_data), clean_data = collect_data(nonoise_dir); end;
if isempty(noise_data), noise_data = collect_data(noise_dir); end;

ts = clean_data.ts;
clean_data.n=1;
noise_data.n=1;



%% Raw plot of learning trajectories, without separation into inter/intra


if ismember(-1, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('Learning Trajectory (Bitwise error)');
    xlabel('training epoch'); ylabel('Bitwise error');
    plot(ts.lesion,      clean_data.all.lei.clsmean, 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      noise_data.all.lei.clsmean, 'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  clean_data.all.lei.clsmean, clean_data.all.lei.clsstd, 'k.');
    errorbar(ts.lesion,  noise_data.all.lei.clsmean, noise_data.all.lei.clsstd, 'k.');
    legend({'Intact (control)', 'Intact (noise)', 'Lesioned (control)', 'Lesioned (noise)' }, 'FontSize', 18);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.0 1.0]);
    set(gca, 'ytick', [0.0:0.25:1.0], 'yticklabel', {'0%' '25%' '50%' '75%' '100%'});
        
    % No noise first
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('Learning Trajectory (Sum-squared error)');
    xlabel('training epoch'); ylabel('Sum-squared Error (average per output)');
    plot(ts.lesion,      clean_data.all.lei.errmean, 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      noise_data.all.lei.errmean, 'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  clean_data.all.lei.errmean, clean_data.all.lei.errstd, 'k.');
    errorbar(ts.lesion,  noise_data.all.lei.errmean, noise_data.all.lei.errstd, 'k.');
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    
    
    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);
end;
    
if ismember(0, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Learning Trajectory (Bitwise error)');
    xlabel('training epoch'); ylabel('% of wrongly classified outputs');
    plot(ts.intact,      mean(clean_data.all.intact.clserr(:,ts.intact),1), 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.intact,      mean(noise_data.all.intact.clserr(:,ts.intact),1), 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 12);
    plot(ts.lesion,      mean(clean_data.all.lesion.clserr,1),              'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    plot(ts.lesion,      mean(noise_data.all.lesion.clserr,1),              'kv:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 12)
    errorbar(ts.intact,  mean(clean_data.all.intact.clserr(:,ts.intact),1), std(clean_data.all.intact.clserr(:,ts.intact),[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.intact,  mean(noise_data.all.intact.clserr(:,ts.intact),1), std(noise_data.all.intact.clserr(:,ts.intact),[],1)/2/sqrt(noise_data.n), 'k.');
    errorbar(ts.lesion,  mean(clean_data.all.lesion.clserr,1),              std(clean_data.all.lesion.clserr,[],1)/2/sqrt(clean_data.n), '.k')
    errorbar(ts.lesion,  mean(noise_data.all.lesion.clserr,1),              std(noise_data.all.lesion.clserr,[],1)/2/sqrt(noise_data.n), '.k')
    legend({'Intact (control)', 'Intact (noise)', 'Lesioned (control)', 'Lesioned (noise)' }, 'FontSize', 18);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.0 1.0]);
    set(gca, 'ytick', [0.0:0.25:1.0], 'yticklabel', {'0%' '25%' '50%' '75%' '100%'});
        
    % No noise first
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('b) Learning Trajectory (Sum-squared error)');
    xlabel('training epoch'); ylabel('Sum-squared Error (average per output)');
    plot(ts.intact,      mean(clean_data.all.intact.err(:,ts.intact),1), 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.intact,      mean(noise_data.all.intact.err(:,ts.intact),1), 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 12);
    plot(ts.lesion,      mean(clean_data.all.lesion.err,1),              'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    plot(ts.lesion,      mean(noise_data.all.lesion.err,1),              'kv:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 12)
    errorbar(ts.intact,  mean(clean_data.all.intact.err(:,ts.intact),1), std(clean_data.intra.intact.err(:,ts.intact),[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.intact,  mean(noise_data.all.intact.err(:,ts.intact),1), std(noise_data.intra.intact.err(:,ts.intact),[],1)/2/sqrt(noise_data.n), 'k.');
    errorbar(ts.lesion,  mean(clean_data.all.lesion.err,1),              std(clean_data.intra.lesion.err,[],1)/2/sqrt(clean_data.n), '.k')
    errorbar(ts.lesion,  mean(noise_data.all.lesion.err,1),              std(noise_data.intra.lesion.err,[],1)/2/sqrt(noise_data.n), '.k')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    
    
    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);
end;
    

%% Raw plot of lesion induced errors
if ismember(0.25, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error (Sum-squared Error)');
    xlabel('training epoch'); ylabel('Sum-squared Error');
    plot(ts.lesion,      clean_data.all.lei.errmean, 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      noise_data.all.lei.errmean, 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  clean_data.all.lei.errmean, clean_data.all.lei.errstd/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  noise_data.all.lei.errmean, noise_data.all.lei.errstd/2/sqrt(noise_data.n), 'k.');
    legend({'Control', 'Noise'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.1 0.8]);
    set(gca, 'ytick', [0.0:0.1:0.6]);

    % No noise first
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error (Bitwise Error)');
    xlabel('training epoch'); ylabel('Bitwise error');
    plot(ts.lesion,      clean_data.all.lei.clsmean, 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      noise_data.all.lei.clsmean, 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  clean_data.all.lei.clsmean, clean_data.all.lei.clsstd/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  noise_data.all.lei.clsmean, noise_data.all.lei.clsstd/2/sqrt(noise_data.n), 'k.');
    legend({'Control', 'Noise'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0 0.8]);
    set(gca, 'ytick', [0.0:0.1:0.6]);

    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);

end;

%% Raw plot of lesion induced errors
if ismember(0.5, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error (Sum-squared Error)');
    xlabel('training epoch'); ylabel('\Delta Sum-squared Error');
    plot(ts.lesion,      mean(clean_data.intra.lei.err,1), 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(noise_data.intra.lei.err,1), 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(clean_data.inter.lei.err,1), 'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(noise_data.inter.lei.err,1), 'kv:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  mean(clean_data.intra.lei.err,1), std(clean_data.intra.lei.err,[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  mean(noise_data.intra.lei.err,1), std(noise_data.intra.lei.err,[],1)/2/sqrt(noise_data.n), 'k.');
    errorbar(ts.lesion,  mean(clean_data.inter.lei.err,1), std(clean_data.inter.lei.err,[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  mean(noise_data.inter.lei.err,1), std(noise_data.inter.lei.err,[],1)/2/sqrt(noise_data.n), 'k.');
    legend({'Intra- (control)', 'Intra- (noise)', 'Inter- (control)', 'Inter- (noise)'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.1 0.8]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    intra_dd_mean = mean(clean_data.intra.lei.err,1) - mean(noise_data.intra.lei.err,1);
    inter_dd_mean = mean(clean_data.inter.lei.err,1) - mean(noise_data.inter.lei.err,1);
    intra_dd_std  = std(clean_data.intra.lei.err,[],1) + std(noise_data.intra.lei.err,[],1);
    inter_dd_std  = std(clean_data.inter.lei.err,[],1) + std(noise_data.inter.lei.err,[],1);
    
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('b) \Delta Lesion-induced error (Sum-squared Error)');
    xlabel('training epoch'); ylabel('\Delta \Delta Sum-squared error');
    plot(100:100:1000, intra_dd_mean, 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, inter_dd_mean, 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k');
    errorbar(100:100:1000, intra_dd_mean, intra_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    errorbar(100:100:1000, inter_dd_mean, inter_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    legend({'Intrahemispheric patterns', 'Interhemispheric patterns', }, 'FontSize', 16);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [-0.05 0.5]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);

end;

%% Raw plot of lesion induced errors
if ismember(0.6, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error (Sum-squared Error)');
    xlabel('training epoch'); ylabel('\Delta Sum-squared Error');
    plot(ts.lesion,      mean(clean_data.inter.lei.err,1), 'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(noise_data.inter.lei.err,1), 'kv:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  mean(clean_data.inter.lei.err,1), std(clean_data.inter.lei.err,[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  mean(noise_data.inter.lei.err,1), std(noise_data.inter.lei.err,[],1)/2/sqrt(noise_data.n), 'k.');
    legend({'Control', 'Noise'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0.1 0.8]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    intra_dd_mean = mean(clean_data.intra.lei.err,1) - mean(noise_data.intra.lei.err,1);
    inter_dd_mean = mean(clean_data.inter.lei.err,1) - mean(noise_data.inter.lei.err,1);
    intra_dd_std  = std(clean_data.intra.lei.err,[],1) + std(noise_data.intra.lei.err,[],1);
    inter_dd_std  = std(clean_data.inter.lei.err,[],1) + std(noise_data.inter.lei.err,[],1);
    
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('b) \Delta Lesion-induced error (Sum-squared Error)');
    xlabel('training epoch'); ylabel('\Delta \Delta Sum-squared error');
    %plot(100:100:1000, intra_dd_mean, 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, inter_dd_mean, 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k');
    %errorbar(100:100:1000, intra_dd_mean, intra_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    errorbar(100:100:1000, inter_dd_mean, inter_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    %legend({'Intrahemispheric patterns', 'Interhemispheric patterns', }, 'FontSize', 16);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [-0.05 0.5]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);

end;

%% Raw plot of lesion induced errors
if ismember(0.75, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error (Bitwise Error)');
    xlabel('training epoch'); ylabel('\Delta bitwise error');
    plot(ts.lesion,      mean(clean_data.intra.lei.cls,1), 'ko-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(noise_data.intra.lei.cls,1), 'kv-', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(clean_data.inter.lei.cls,1), 'ko:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    plot(ts.lesion,      mean(noise_data.inter.lei.cls,1), 'kv:', 'LineWidth', 3, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion,  mean(clean_data.intra.lei.cls,1), std(clean_data.intra.lei.cls,[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  mean(noise_data.intra.lei.cls,1), std(noise_data.intra.lei.cls,[],1)/2/sqrt(noise_data.n), 'k.');
    errorbar(ts.lesion,  mean(clean_data.inter.lei.cls,1), std(clean_data.inter.lei.cls,[],1)/2/sqrt(clean_data.n), 'k.');
    errorbar(ts.lesion,  mean(noise_data.inter.lei.cls,1), std(noise_data.inter.lei.cls,[],1)/2/sqrt(noise_data.n), 'k.');
    legend({'Intra- (control)', 'Intra- (noise)', 'Inter- (control)', 'Inter- (noise)'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [0 0.8]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    intra_dd_mean = mean(clean_data.intra.lei.cls,1) - mean(noise_data.intra.lei.cls,1);
    inter_dd_mean = mean(clean_data.inter.lei.cls,1) - mean(noise_data.inter.lei.cls,1);
    intra_dd_std  = std(clean_data.intra.lei.cls,[],1) + std(noise_data.intra.lei.cls,[],1);
    inter_dd_std  = std(clean_data.inter.lei.cls,[],1) + std(noise_data.inter.lei.cls,[],1);
    
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('b) \Delta Lesion-induced error (Bitwise Error)');
    xlabel('training epoch'); ylabel('\Delta \Delta bitwise error');
    plot(100:100:1000, intra_dd_mean, 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, inter_dd_mean, 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k');
    errorbar(100:100:1000, intra_dd_mean, intra_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    errorbar(100:100:1000, inter_dd_mean, inter_dd_std/2/sqrt(clean_data.n+noise_data.n), 'k.');
    legend({'Intrahemispheric patterns', 'Interhemispheric patterns', }, 'FontSize', 16);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 1025], 'ylim', [-0.05 0.5]);
    set(gca, 'ytick', [0.0:0.1:0.6]);


    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);

end;
    
    
%% Raw plot of learning trajectories
if ismember(1, plots)
    figure;
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('Learning Trajectory (control)');
    xlabel('training epoch'); ylabel('Error (sum-squared error)');
    plot(1:5:1000, mean(clean_data.intra.intact.err(:,1:5:end),1), 'k:', 'LineWidth', 2);
    plot(1:5:1000, mean(clean_data.inter.intact.err(:,1:5:end),1), 'k-', 'LineWidth', 2);
    plot(100:100:1000, mean(clean_data.intra.lesion.err,1), 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, mean(clean_data.inter.lesion.err,1), 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    errorbar(1:100:1000, mean(clean_data.intra.intact.err(:,1:100:end),1), std(clean_data.intra.intact.err(:,1:100:end),[],1), 'k.');
    errorbar(1:100:1000, mean(clean_data.inter.intact.err(:,1:100:end),1), std(clean_data.inter.intact.err(:,1:100:end),[],1), 'k.');
    errorbar(100:100:1000, mean(clean_data.intra.lesion.err,1), std(clean_data.intra.lesion.err,[],1), '.k')
    errorbar(100:100:1000, mean(clean_data.inter.lesion.err,1), std(clean_data.inter.lesion.err,[],1), '.k')
    legend({'Intact, intra-hemi patterns', 'Intact, inter-hemi patterns', 'Lesioned, intra-hemi patterns', 'Lesioned, inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    

    % Noise second
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('Learning Trajectory (noisy)');
    xlabel('training epoch'); ylabel('Error (sum-squared error)');
    plot(1:5:1000, mean(noise_data.intra.intact.err(:,1:5:end),1), 'k:', 'LineWidth', 2);
    plot(1:5:1000, mean(noise_data.inter.intact.err(:,1:5:end),1), 'k-', 'LineWidth', 2);
    plot(100:100:1000, mean(noise_data.intra.lesion.err,1), 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, mean(noise_data.inter.lesion.err,1), 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    errorbar(1:100:1000, mean(noise_data.intra.intact.err(:,1:100:end),1), std(noise_data.intra.intact.err(:,1:100:end),[],1), 'k.');
    errorbar(1:100:1000, mean(noise_data.inter.intact.err(:,1:100:end),1), std(noise_data.inter.intact.err(:,1:100:end),[],1), 'k.');
    errorbar(100:100:1000, mean(noise_data.intra.lesion.err,1), std(noise_data.intra.lesion.err,[],1), '.k')
    errorbar(100:100:1000, mean(noise_data.inter.lesion.err,1), std(noise_data.inter.lesion.err,[],1), '.k')
    legend({'Intact, intra-hemi patterns', 'Intact, inter-hemi patterns', 'Lesioned, intra-hemi patterns', 'Lesioned, inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    
    
    %set(gcf, 'Position', [  5         -21        1276         705]);
end;

%% Plot of differences between error pre- and post- lesion, for intra- and
%% inter-
if ismember(2, plots)
    figure;
    
    
    % No noise first
    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('Difference in error, intact vs. lesioned (control)');
    xlabel('training epoch'); ylabel('Error (sum-squared error)');
    plot(100:100:1000, mean(clean_data.intra.errdiff,1), 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, mean(clean_data.inter.errdiff,1), 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k');
    errorbar(100:100:1000, mean(clean_data.intra.errdiff,1), std(clean_data.intra.errdiff,[],1), 'k');
    errorbar(100:100:1000, mean(clean_data.inter.errdiff,1), std(clean_data.inter.errdiff,[],1), 'k');
    legend({'Intra-hemi patterns', 'Inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    

    % Noise second
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('Difference in error, intact vs. lesioned (Noise)');
    xlabel('training epoch'); ylabel('Error (sum-squared error)');
    plot(100:100:1000, mean(noise_data.intra.errdiff,1), 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, mean(noise_data.inter.errdiff,1), 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    errorbar(100:100:1000, mean(noise_data.intra.errdiff,1), std(noise_data.intra.errdiff,[],1), 'k');
    errorbar(100:100:1000, mean(noise_data.inter.errdiff,1), std(noise_data.inter.errdiff,[],1), 'k');
    legend({'Intra-hemi patterns', 'Inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [0.0 0.7]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    
    
    %set(gcf, 'Position', [  5         -21        1276         705]);
end;

%% Now the same, but on different axes!
if ismember(3, plots)
    
    intra_dd_mean = mean(clean_data.intra.lei.err,1) - mean(noise_data.intra.lei.err,1);
    inter_dd_mean = mean(clean_data.inter.lei.err,1) - mean(noise_data.inter.lei.err,1);
    
    figure;
    hold on;
    set(gca, 'FontSize', 18);
    title('Difference in error, intact vs. lesioned (Control)');
    xlabel('training epoch'); ylabel('Error (sum-squared error)');
    plot(100:100:1000, intra_dd_mean, 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, inter_dd_mean, 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k');
%    errorbar(100:100:1000, mean(intra_diffdiff,1), std(intra_diffdiff,[],1), 'k');
%    errorbar(100:100:1000, mean(inter_diffdiff,1), std(inter_diffdiff,[],1), 'k');
    legend({'Intra-hemi patterns', 'Inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [-.5 0.5]);
    set(gca, 'ytick', [0.0:0.1:0.6]);
    
end;

%% Raw plot of learning trajectories, as % bits correct
if ismember(4, plots)

    intra_dd_mean = mean(clean_data.intra.lei.cls,1) - mean(noise_data.intra.lei.cls,1);
    inter_dd_mean = mean(clean_data.inter.lei.cls,1) - mean(noise_data.inter.lei.cls,1);
    
    figure;
    hold on;
    set(gca, 'FontSize', 18);
    title('Difference in control vs. noise in lesion-induced error');
    xlabel('training epoch'); ylabel('Lesion-induced Error');
    plot(100:100:1000, intra_dd_mean, 'ko:', 'LineWidth', 2, 'MarkerFaceColor', 'k')
    plot(100:100:1000, inter_dd_mean, 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k');
%    errorbar(100:100:1000, mean(intra_diffdiff,1), std(intra_diffdiff,[],1), 'k');
%    errorbar(100:100:1000, mean(inter_diffdiff,1), std(inter_diffdiff,[],1), 'k');
    legend({'Intra-hemi patterns', 'Inter-hemi patterns', }, 'FontSize', 14);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'ylim', [-0.1 0.5]);
    set(gca, 'ytick', [0.0:0.1:0.6]);

end;

  

