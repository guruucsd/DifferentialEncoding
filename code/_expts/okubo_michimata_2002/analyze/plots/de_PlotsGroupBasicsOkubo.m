function figs = de_PlotsGroupBasicsOkubo( all_mSets, stats )

    n_expts = length(all_mSets);
    expt_names = cellfun(@(mSets) mSets.data.taskType, all_mSets, 'UniformOutput', false)
    stim_names = cellfun(@(mSets) mSets.data.stimSet, all_mSets, 'UniformOutput', false)
    guru_assert(n_expts == 4, 'Okubo should have four experiments.')

    figs = de_NewFig('okubo-figure2');

    stims = {'dots', 'dots-cb'};  % This orders the plots.
    n_stim_sets = length(stims);
    for si=1:n_stim_sets
        % rows are experiments, cols are hemis
        expt_idx = ismember(stim_names, stims{si})
        hemi_idx = [1 size(stats.median_sse, 2)]; % first and last

        % NOTE the use of MEDIAN error (as specified in the paper)
        subplot(1, n_stim_sets, si);
        errorbar([1 1; 2 2;], stats.median_sse(expt_idx, hemi_idx), ...
                 stats.std_sse(expt_idx, hemi_idx), 'LineWidth', 3.0);

        set(gca, 'xtick', 1:2, 'xticklabel', expt_names(expt_idx));
        set(gca, 'xlim', [0.5, 2.5]);
        set(gca, 'ylim', [min(stats.median_sse(:) - stats.stderr_sse(:)) ...
                          max(stats.median_sse(:) + stats.stderr_sse(:))] ...;
                         .* [0.9 1.1]);
        legend({'RH', 'LH'});
        title(stims{si});
    end;
