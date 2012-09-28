function stats = de_PlotsGroupBasicsKit( mSets, ms, ss )

  ds = 'test';

  % Get mean and std for each hemi in each task
  means = [ mean(ss.group.anova.(ds).X(1:ss.group.anova.(ds).nRepeats,1)) ...
            mean(ss.group.anova.(ds).X(1:ss.group.anova.(ds).nRepeats,2)) ; ...
            mean(ss.group.anova.(ds).X((1+ss.group.anova.(ds).nRepeats):end,1)) ...
            mean(ss.group.anova.(ds).X((1+ss.group.anova.(ds).nRepeats):end,2)) ];

perf = log10(means'); %means are rows=task,cols=hemi; perf is opposite

hemi_lbls = { sprintf('RH (\\sigma=%3.1f)', mSets.sigma(1)), ...
              sprintf('LH (\\sigma=%3.1f)', mSets.sigma(2))};
task_lbls = {'Wide/Narrow','Sharp/Fuzzy'};

figure; hold on;

plot(1, perf(1,2), 'ko', 'MarkerSize', 15.0, 'MarkerFaceColor','k');
plot(1, perf(1,1), 'ko', 'MarkerSize', 15.0);
plot(2, perf(2,2), 'ko', 'MarkerSize', 15.0, 'MarkerFaceColor','k');
plot(2, perf(2,1), 'ko', 'MarkerSize', 15.0);
plot([1 2], perf(:,1), 'k', 'LineWidth', 2.0);
plot([1 2], perf(:,2), 'k', 'LineWidth', 2.0);

xlim([0.45 2.75+.8]);
set(gca, 'FontSize', 18.0, 'xtick', [1 2], 'xticklabel', task_lbls);
%legend(hemi_lbls, 'Location', 'NorthEast');
text(2.125, perf(2,1), hemi_lbls{1}, 'FontSize', 18)
text(2.125, perf(2,2), hemi_lbls{2}, 'FontSize', 18)
ylabel('log_{10}(Mean Square Error)');

print(gcf, '-dpng', 'test');