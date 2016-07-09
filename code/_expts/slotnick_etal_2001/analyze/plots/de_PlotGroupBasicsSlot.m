function figs = de_PlotGroupBasicsSlot( ms, ss )

    data = {ss.cate; ss.coor};
    models = {ms.cate; ms.coor};
    ds = 'test';
    num_ttypes = size(data, 1);
    trial_types = data{1}.rej.cc.anova.(ds).trial_types;

    for tri = 1:length(trial_types)  % trial type
        trial_type = trial_types{tri};
        fig = de_NewFig(sprintf('blobdot_comparison_%s', trial_type));
        yrng = 0;

        for tai = 1:length(data)  % task type
            mSets = models{tai}(1);
            taskTitle = guru_capitalizeStr(mSets.data.taskType);
            stimSet = mSets.data.stimSet;

            right = data{tai}.rej.cc.perf.(ds){1}{tri};
            left = data{tai}.rej.cc.perf.(ds){end}{tri};
            runs = min(length(models{1}), length(models{end}));

            left_mean = mean(left(:));
            right_mean = mean(right(:));
            left_stderr = std(mean(left, 2)) / sqrt(size(left, 1));
            right_stderr = std(mean(right, 2)) / sqrt(size(right, 1));

            ax(tai) = subplot(1, num_ttypes, tai);
            de_CreateSlotnickFigure1([left_mean right_mean], ...
                                     [left_stderr right_stderr], ...
                                     taskTitle, stimSet, runs, ax(tai));

            % Store properties to correct axes
            avg(tai) = mean([left_mean, right_mean]);
            yrng = max(yrng, abs(left_mean - right_mean));
        end

        for tai = 1:num_ttypes
            % Only need yrng/2 for full range, but 2* yrng for room for error bar
            set(ax(tai), 'ylim', avg(tai) + 2*[-1, 1])
        end
    end;
    
    figs = [fig];

