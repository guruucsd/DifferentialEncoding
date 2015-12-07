function figs = de_PlotGroupBasicsSlot( ms, ss )

    data = {ss.cate; ss.coor};
    models = {ms.cate; ms.coor};
    ds = 'test';
    num_ttypes = size(data, 1);
    trial_types = data{1}.rej.cc.perf.(ds){1}.trial_types;

    for tri = 1:length(trial_types)  % trial type
        trial_type = trial_types{tri};
        fig = de_NewFig(sprintf('blobdot_comparison_%s', trial_type);
        yrng = 0;

        for tai = 1:length(data)  % task type
            mSets = models{tt}(1);
            taskTitle = guru_capitalizeStr(mSets.data.taskType);
            stimSet = mSets.data.stimSet;

            right = data{tt}.rej.cc.perf.(ds){1}{tri};
            left = data{tt}.rej.cc.perf.(ds){end}{tri};
            rons = min(length(models{1}), length(models{end}));

            left_mean = mean(left(:));
            right_mean = mean(right(:));
            left_stderr = std(mean(left, 2)) / sqrt(size(left, 1));
            right_stderr = std(mean(left, 2)) / sqrt(size(right, 1));

            ax(tt) = subplot(1, num_ttypes, tt);
            de_CreateSlotnickFigure1([left_mean right_mean], ...
                                     [left_stderr right_stderr], ...
                                     taskTitle, stimSet, rons, ax(tt));

            % Store properties to correct axes
            avg(tt) = mean([left_mean, right_mean]);
            yrng = max(yrng, abs(left_mean - right_mean));
        end

        for tt = 1:num_ttypes
            % Only need yrng/2 for full range, but 2* yrng for room for error bar
            set(ax(tt), 'ylim', avg(tt) + 2*[-1, 1])
        end
    end;
