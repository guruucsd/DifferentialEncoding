% Recreate figures 2, 3 and 4.

% Add paths
script_dir = fileparts(which(mfilename));
base_dir = fullfile(script_dir, '..', '..', '..');
addpath(genpath(fullfile(base_dir, 'code')));
for d={'34x25', '68x50'}  % this is the path ordering
    full_path = fullfile(script_dir, '..', '..', d{1}, 'slotnick_etal_2001');
    addpath(full_path, '-end');
end;

% Scripts ordered by figure 2/3/4 order.
ds = 'test';
all_scripts = {'uber_slotnick_blobdot_categorical', ...
              'uber_slotnick_plusminus_categorical', ...
              'uber_slotnick_blobdot_coordinate', ...
              'uber_slotnick_plusminus_coordinate', ...
              'uber_slotnick_pairedsquares_coordinate'};

% We will incrementally build each figure.
figs = de_NewFig('dummy');
figs(end+1) = de_NewFig('slotnick_figure_2');
figs(end+1) = de_NewFig('slotnick_figure_3');
figs(end+1) = de_NewFig('slotnick_figure_4');
fhs = arrayfun(@(f) f.handle, figs, 'UniformOutput', false); %compatible in 2015
n_figs = length(figs);

ymax = zeros(n_figs, 1);
n_scripts = length(all_scripts);
for si=1:n_scripts
    script_file = all_scripts{si};

    % Run the script, alias the outputs, close any open handles.
    fprintf('Running %s...\n',script_file);
    eval(script_file);
    stats = tst.stats;
    mSets = tst.mSets;
    for ii=1:100  % close all unrecognized figures.
        if ~(any(cellfun(@(x) isequal(x, gcf), fhs))), close(gcf); %2015
        else, break; end;
    end;

    % Plot each figure
    right = stats.rej.cc.perf.(ds){1};
    left = stats.rej.cc.perf.(ds){end};
    runs = mSets.runs;

    n_trial_types = length(left);
    for fi=1:n_figs
        figure(figs(fi).handle);
        set(gcf, 'Position', [0, 0, 1200, 600]);

        if fi == 1
            left_mean = mean(cellfun(@(d) mean(d(:)), left));
            right_mean = mean(cellfun(@(d) mean(d(:)), right));
            left_stderr = 0 * left_mean;  % feeling lazy; errorbars are clear
            right_stderr = 0 * right_mean; % on other subplots.
            taskTitle = guru_capitalizeStr(mSets.data.taskType);

        else
            ti = fi - 1;
            left_mean = mean(left{ti}(:));
            right_mean = mean(right{ti}(:));

            % Average over trials to get a single score per network,
            % then find stderr over all networks.
            left_stderr = std(mean(left{ti}, 2)) / sqrt(size(left{ti}, 1));
            right_stderr = std(mean(right{ti}, 2)) / sqrt(size(right{ti}, 1));

            taskTitle = sprintf('%s (%s)', ...
                                guru_capitalizeStr(mSets.data.taskType), ...
                                guru_capitalizeStr(stats.rej.cc.anova.(ds).trial_types{ti}));
        end;

        ax = subplot(1, n_scripts, si);
        de_CreateSlotnickFigure1([left_mean right_mean], ...
                                 [left_stderr right_stderr], ...
                                 taskTitle, mSets.data.stimSet, ...
                                 runs, ax);

        if si ~= round(n_scripts/2)
            xlabel('');  % remove label
        end;
        if si ~= 1
            ylabel('');
            set(gca, 'ytick', []);
        end;

        % Set the axes equally.
        yl = get(gca, 'ylim');
        ymax(fi) = max(yl(2), ymax(fi));
        for sxi=1:si
            ax2 = subplot(1, n_scripts, sxi);
            set(ax2, 'xlim', [0.5, 2.5], 'ylim', [0 ymax(fi)]);
        end;
    end;

    % Save on every loop, for good measure.
    mSets.out.plots = {'png', 'fig'};
    mSets.out.stem = fullfile(fileparts(mSets.out.stem), mfilename);
    de_SavePlots(mSets, figs);
end;

