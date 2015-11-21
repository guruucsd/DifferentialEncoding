function figs = de_PlotGroupBasicsSlot( ms, ss )

data = {ss.cate; ss.coor};
models = {ms.cate; ms.coor};
ds = 'test';
num_ttypes = size(data, 1);
fig = de_NewFig('blobdot_comparison');
yrng = 0;

for tt = 1:num_ttypes
    taskTitle = guru_capitalizeStr(models{tt}(1).data.taskType);
    left = data{tt}.rej.cc.perf.(ds){1};
    right = data{tt}.rej.cc.perf.(ds){end};
    rons = models{1}(1).runs;

    % these results are for on/near
    left_results1 = left{1};
    right_results1 = right{1};
    
    %these results are for off/far
    left_results2 = left{2};
    right_results2 = right{2};
    
    % combine them into a single results matrix
    left_results = [left_results1, left_results2];
    right_results = [right_results1, right_results2];
    
    left_average = mean(left_results(:)');
    right_average = mean(right_results(:)');
    avg(tt) = mean([left_average, right_average]);
    yrng = max(yrng, left_average-right_average);
    
    left_stderr = std(mean(left_results, 2)) / sqrt(size(left_results, 1));
    right_stderr = std(mean(right_results, 2)) / sqrt(size(right_results, 1));
    ax(tt) = subplot(1, num_ttypes, tt);
    de_CreateSlotnickFigure1([left_average right_average], [left_stderr right_stderr], taskTitle, rons, ax(tt));

end

for tt = 1:num_ttypes
    minimum = avg(tt) - 2*yrng; % Only need yrng/2 for full range, but 2* yrng for room for error bar
    maximum = avg(tt) + 2*yrng;
    yrange=[minimum, maximum];
    set(ax(tt), 'ylim', yrange)
end

figs = [fig];

end