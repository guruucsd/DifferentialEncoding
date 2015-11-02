function figs = de_FigurizerCC(mSets, mss, stats)
%% Still needed:
% 1) Make the plots prettier.
% 2) Implement code that generalizes based on the task (blob/dot vs paired
% squares etc)

ds = 'test';

left = stats.rej.cc.perf.(ds){1};
right = stats.rej.cc.perf.(ds){2};
if strcmp(mSets.data.taskType, 'categorical') 
    left_results = left{1};
    right_results = right{1};

elseif strcmp(mSets.data.taskType, 'coordinate') 
    left_results = left{2};
    right_results = right{2};

else
    error('taskType is neither categorical nor coordinate');
end


rons = size(left_results, 1);

left_average = mean(mean(left_results, 2));
right_average = mean(mean(right_results, 2));

left_stddev = std(mean(left_results, 2));
right_stddev = std(mean(right_results, 2));

fig = de_CreateSlotnickFigure1([left_average right_average], [left_stddev right_stddev], mSets.data.taskType, rons);
figs = [fig];
