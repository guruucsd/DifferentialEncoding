ringo_etal_1994_data = [97  93  64 58 40 42 38 37 33
                        75  62  48 41 43 40 39 42 31];
ringo_etal_1994_err  = [1.2 1.2  3  3  3  3  3  3  5
                          3   3  3  3  3  3  3  3  5];
     
ringo_etal_1994_t=[15:5:50 75];

figure;
set(gcf, 'Position', [       5         160        1276         514]);

subplot(1,2,1);
hold on;
set(gca, 'LooseInset', get(gca,'TightInset'))
set(gca, 'FontSize', 18);
set(gca, 'xtick', [10:10:80], 'ytick', 40:20:100);
set(gca, 'xlim', [10 85], 'ylim', [25 100]);
plot(ringo_etal_1994_t,ringo_etal_1994_data(1,:), '-ok', 'LineWidth', 2, 'MarkerSize', 12, 'MarkerFaceColor', 'k');
plot(ringo_etal_1994_t,ringo_etal_1994_data(2,:), '-vk', 'LineWidth', 2, 'MarkerSize', 12);
errorbar(ringo_etal_1994_t, ringo_etal_1994_data(1,:), ringo_etal_1994_err(1,:), 'k');
errorbar(ringo_etal_1994_t, ringo_etal_1994_data(2,:), ringo_etal_1994_err(2,:), 'k');
legend({'Delay=10 ' 'Delay=1'});
title('a. Original Ringo et al. (1994) data');
xlabel('time steps');
ylabel('% correct output patterns ')

drawnow;
pos1 = get(gca, 'Position');

subplot(1,2,2);
hold on;
%set(gca, 'Position', [0.55 pos2(2:end)]);%0.2086    0.2799    0.6489])
set(gca, 'FontSize', 18);
set(gca, 'LooseInset', get(gca,'TightInset'))
set(gca, 'xtick', [10:10:80], 'ytick', 40:20:100);
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
