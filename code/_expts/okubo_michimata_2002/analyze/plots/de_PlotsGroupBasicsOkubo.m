function figs = de_PlotsGroupBasicsOkubo( all_mSets, stats )

n_expts = length(all_mSets);
expt_names = cellfun(@(mSets) mSets.data.taskType, all_mSets, 'UniformOutput', false);
stim_names = cellfun(@(mSets) mSets.data.stimSet, all_mSets, 'UniformOutput', false);
guru_assert(n_expts == 4, 'Okubo should have four experiments.')

figs = de_NewFig('okubo-figure2')

for si=1:2
    % rows are experiments, cols are hemis
    expt_idx = 2 * (si - 1) + [1:2];
    hemi_idx = [1 size(stats.median_error, 2)];

    % NOTE the use of MEDIAN error (as specified in the paper)
    subplot(1, 2, si);
    errorbar([1 1; 2 2;], stats.median_error(expt_idx, hemi_idx), stats.std_error(expt_idx, hemi_idx), 'LineWidth', 3.0);

    set(gca, 'xtick', 1:2, 'xticklabel', expt_names(expt_idx));
    set(gca, 'xlim', [0.5, 2.5]);
    set(gca, 'ylim', [min(stats.median_error(:) - stats.std_error(:)) ...
                      max(stats.median_error(:) + stats.std_error(:))] ...;
                     .* [0.9 1.1]);
    legend({'RH', 'LH'});
    title(stim_names(expt_idx(1)));
end;
