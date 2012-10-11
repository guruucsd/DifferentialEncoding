% This is from Table III, condition B (p. 103)

figure;
bar(1.-[0.46 0.22])
set(gca, 'xtick', [1 2], 'xticklabel', {'RH (LVF)', 'LH (RVF)'})
set(gca, 'ytick', [0, 0.5, 1])
set(gca, 'ylim', [0 1], 'xlim', [0.5 2.5])
ylabel('Error', 'FontSize', 24)
set(gca, 'FontSize', 24)

