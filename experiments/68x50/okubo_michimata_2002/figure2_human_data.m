%                  LVF  RVF
om_2002_figure2 = [570, 555; ... % bright categorical
                   632, 660; ... % bright coordinate
                   608, 593;     ... % cb categorical
                   692, 684];   

% mean of categorical should be [589, 574]--it is.
% mean of coordinate should be [662, 672] -- use it to fill in missing data.
% LVF: 662 = (632 + x)/2; x = 662*2 - 632 = 692
% RVF: 672 = (660 + x)/2; x = 672*2 - 660 = 684

mean(om_2002_figure2([1 3], :), 1)
mean(om_2002_figure2([2 4], :), 1)

% now, plot figure 2.
figure('position', [0, 0, 800, 419]);
xvals = repmat([1 2], [2 1])';

subplot(1, 2, 1);
h = plot(xvals, om_2002_figure2([1 2], :), 'k');
set(h(1), {'Marker'}, {'s'}, {'MarkerFaceColor'}, {'k'});
set(h(2), {'Marker'}, {'o'});
set(gca, 'xtick', xvals(:, 1), 'xticklabel', {'CATE', 'COOR'})
set(gca, 'xlim', [xvals(1, 1) xvals(2, 1)] + 0.5*[-1 1]);
set(gca, 'ylim', [525, 725]);
xlabel('Spatial relation task');
ylabel('Reaction time (msec)');
title('Bright');

subplot(1, 2, 2);
h = plot(xvals, om_2002_figure2([3 4], :), 'k');
set(h(1), {'Marker'}, {'s'}, {'MarkerFaceColor'}, {'k'});
set(h(2), {'Marker'}, {'o'});
set(gca, 'xtick', xvals(:, 1), 'xticklabel', {'CATE', 'COOR'})
set(gca, 'xlim', [xvals(1, 1) xvals(2, 1)] + 0.5*[-1 1]);
set(gca, 'ylim', [525, 725]);
xlabel('Spatial relation task');
title('CB');
legend({'LVF-RH' 'RVF-LH'});