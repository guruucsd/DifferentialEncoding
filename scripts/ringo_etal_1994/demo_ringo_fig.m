function demo_ringo_fig(figs)
%
    if ~exist('figs','var'), figs = {'all'}; end;
    
    ringo_etal_1994_data = [97  93  64 58 40 42 38 37 33
                            75  62  48 41 43 40 39 42 31];
    ringo_etal_1994_err  = [1.2 1.2  3  3  3  3  3  3  5
                              3   3  3  3  3  3  3  3  5];
    ringo_etal_1994_t=[15:5:50 75];

    for i=1:length(figs)

        
        if ismember('original', figs) || ismember('all', figs)
            % Original ringo figure, with shift
            figure;
            set(gcf, 'Position', [       5         160        1276         514]);

            subplot(1,2,1);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [25 100]);
            plot(ringo_etal_1994_t,ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            plot(ringo_etal_1994_t,ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');
            legend({'Delay=10 ' 'Delay=1'});
            title('a. Original Ringo et al. (1994) data');
            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
            pos1 = get(gca, 'Position');

            subplot(1,2,2);
            hold on;
            %set(gca, 'Position', [0.55 pos2(2:end)]);%0.2086    0.2799    0.6489])
            set(gca, 'FontSize', 18);
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 85], 'ylim', [25 100]);
            plot(ringo_etal_1994_t,  ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            plot(ringo_etal_1994_t+9,ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 10);
            %plot(ringo_etal_1994_t,  ringo_etal_1994_data(2,:), '--vk', 'LineWidth', 1, 'MarkerSize', 10);
            errorbar(ringo_etal_1994_t,   ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            errorbar(ringo_etal_1994_t+9, ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');

            legend({'Delay=10 ' 'Delay=1'});
            title('b. Delay=1 shifted by 9 time-steps ');
            xlabel('time steps');

            drawnow;
            pos2 = get(gca, 'Position');

            set(gca, 'Position', [0.57 pos2(2:end)]);%0.2086    0.2799    0.6489])
        end;
 
        if ismember('original-reversed', figs) || ismember('all', figs)
            % Original ringo figure, with shift
            figure;
            set(gcf, 'Position', [       5         160        1276         514]);

            subplot(1,2,1);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [0:20:60]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [0 85]);
            plot(ringo_etal_1994_t, 100-ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            plot(ringo_etal_1994_t, 100-ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            errorbar(ringo_etal_1994_t, 100-ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            errorbar(ringo_etal_1994_t, 100-ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');
            legend({'Delay=10 ' 'Delay=1'}, 'Location', 'NorthWest');
            title('a. Original Ringo et al. (1994) data');
            xlabel('time steps');
            ylabel('Change in [% errors]')

            drawnow;
            pos1 = get(gca, 'Position');

            subplot(1,2,2);
            hold on;
            %set(gca, 'Position', [0.55 pos2(2:end)]);%0.2086    0.2799    0.6489])
            set(gca, 'FontSize', 18);
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'xtick', [15:10:75], 'ytick', [0:20:60]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 85], 'ylim', [0 85]);
            plot(ringo_etal_1994_t,  100-ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            plot(ringo_etal_1994_t+9,100-ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 10);
            %plot(ringo_etal_1994_t,  ringo_etal_1994_data(2,:), '--vk', 'LineWidth', 1, 'MarkerSize', 10);
            errorbar(ringo_etal_1994_t,   100-ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            errorbar(ringo_etal_1994_t+9, 100-ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');

            legend({'Delay=10 ' 'Delay=1'}, 'Location', 'NorthWest');
            title('b. Delay=1 shifted by 9 time-steps ');
            xlabel('time steps');

            drawnow;
            pos2 = get(gca, 'Position');

            set(gca, 'Position', [0.57 pos2(2:end)]);%0.2086    0.2799    0.6489])
        end;

        if ismember('parts', figs) || ismember('all', figs)
            % Show the original ringo figure as separate parts.
            figure;
            set(gcf, 'Position', [       5         160        1276         514]);

            subplot(1,2,1);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 85], 'ylim', [25 100]);
            plot(ringo_etal_1994_t,ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');
            legend({'Delay=1'});
            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
            pos1 = get(gca, 'Position');

            subplot(1,2,2);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [25 100]);
            plot(ringo_etal_1994_t,ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
            pos1 = get(gca, 'Position');
            legend({'Delay=10 '});
            xlabel('time steps');

            drawnow;
            pos2 = get(gca, 'Position');

            set(gca, 'Position', [0.57 pos2(2:end)]);%0.2086    0.2799    0.6489])
        end;
        
        if ismember('parts-reversed', figs) || ismember('all', figs)
            % Show the original ringo figure as separate parts.
            figure;
            set(gcf, 'Position', [       5         160        1276         514]);

            subplot(1,2,1);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [0:20:60]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [0 85]);
            plot(ringo_etal_1994_t, 100-ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            errorbar(ringo_etal_1994_t, 100-ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');
            legend({'Delay=1'}, 'Location', 'NorthWest');
            xlabel('time steps');
            ylabel('Change in [% errors]')

            drawnow;
            pos1 = get(gca, 'Position');
            subplot(1,2,2);
            hold on;
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [0:20:60]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [0 85]);
            plot(ringo_etal_1994_t, 100-ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            errorbar(ringo_etal_1994_t, 100-ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
            pos1 = get(gca, 'Position');
            xlabel('time steps');
            ylabel('Change in [% errors]')

            drawnow;
            legend({'Delay=10 '}, 'Location', 'NorthWest');

            drawnow;
            pos2 = get(gca, 'Position');

            set(gca, 'Position', [0.57 pos2(2:end)]);%0.2086    0.2799    0.6489])
        end;


        if ismember('parts-animated', figs) || ismember('all', figs)
            % Show the original ringo figure as separate parts.
            figure;
            set(gcf, 'Position', [       5         160        800         600]);
            plot(ringo_etal_1994_t,ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            hold on;
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k', 'LineWidth', 1.5);

            % Original ringo figure, with shift
            set(gcf, 'Position', [       5         160        800         600]);
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [25 100]);

            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
            
            
            figure;
            set(gcf, 'Position', [       5         160        800         600]);
            plot(ringo_etal_1994_t,  ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            hold on;
            errorbar(ringo_etal_1994_t,   ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k', 'LineWidth', 1.5);

            set(gca, 'FontSize', 18);
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [25 100]);

            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
        end;

        if ismember('animated', figs) || ismember('all', figs)
            % Show the original ringo figure as separate parts.
            figure;
            set(gcf, 'Position', [       5         160        800         600]);
            plot(ringo_etal_1994_t,ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
            hold on;
            plot(ringo_etal_1994_t,  ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
            errorbar(ringo_etal_1994_t,   ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k', 'LineWidth', 1.5);
            errorbar(ringo_etal_1994_t, ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k', 'LineWidth', 1.5);

            % Original ringo figure, with shift
            set(gcf, 'Position', [       5         160        800         600]);
            set(gca, 'LooseInset', get(gca,'TightInset'))
            set(gca, 'FontSize', 18);
            set(gca, 'xtick', [15:10:75], 'ytick', [40:20:100]);
            set(gca, 'yticklabel', cellfun(@(c) sprintf('%d%%',c), num2cell(get(gca, 'ytick')), 'UniformOutput', 0));
            set(gca, 'xlim', [10 80], 'ylim', [25 100]);

            xlabel('time steps');
            ylabel('Change in [% correct output patterns]')

            drawnow;
        end;
    end;
