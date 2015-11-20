function stats = de_PlotGroupBasicsSlot( ms, ss )
data = {ss.cate; ss.coor};
models = {ms.cate; ms.coor};
ds = 'test';
num_ttypes = size(data, 1);
figure;
left_average = {0, 0};
right_average = {0, 0};
left_stderr = {0, 0};
right_stderr = {0, 0};
taskTitle = {'', ''};
rons = {0, 0};
for tt = 1:num_ttypes
    taskTitle{tt} = guru_capitalizeStr(models{tt}(1).data.taskType);
    left = data{tt}.rej.cc.perf.(ds){1};
    right = data{tt}.rej.cc.perf.(ds){end};
    rons{tt} = min(length(left), length(right));

    % these results are for on/near
    left_results1 = left{1};
    right_results1 = right{1};
    
    %these results are for off/far
    left_results2 = left{2};
    right_results2 = right{2};
    
    % combine them into a single results matrix
    left_results = [left_results1, left_results2];
    right_results = [right_results1, right_results2];
    
    left_average{tt} = mean(left_results(:)');
    right_average{tt} = mean(right_results(:)');
    
    left_stderr{tt} = std(mean(left_results, 2)) / sqrt(size(left_results, 1));
    right_stderr{tt} = std(mean(right_results, 2)) / sqrt(size(right_results, 1));
end
    yrange = max(abs(left_average{1}-right_average{1}), abs(left_average{2}-right_average{2}));
for tt = 1:num_ttypes
    ax = subplot(1, num_ttypes, tt);
    de_CreateSlotnickFigure1([left_average{tt} right_average{tt}], [left_stderr{tt} right_stderr{tt}], taskTitle{tt}, rons{tt}, ax, yrange);
end

end