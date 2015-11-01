%% Still needed:
% 1) Make the plots prettier.
% 2) Implement code that generalizes based on the task (blob/dot vs paired
% squares etc)


function figs = de_FigurizerCC(mSets, mss, stats)

ds = 'test';

left = stats.rej.cc.perf.(ds){1};
right = stats.rej.cc.perf.(ds){2};

if strcmp(mSets.data.taskType, 'categorical') 
    
    left_results = left{1};
    right_results = right{1};
    
    left_average = mean(left_results(:)');
    right_average = mean(right_results(:)');
    
    left_stddev = std(left_results(:)');
    right_stddev = std(right_results(:)');
    fig = createfigure([left_average right_average], [left_stddev right_stddev], 'Categorical');
    figs = [fig];

elseif strcmp(mSets.data.taskType, 'coordinate') 
    
    left_results = left{2};
    right_results = right{2};
    
    left_average = mean(left_results(:)');
    right_average = mean(right_results(:)');
    
    left_stddev = std(left_results(:)');
    right_stddev = std(right_results(:)');
    fig = createfigure([left_average right_average], [left_stddev right_stddev], 'Coordinate');
    figs = [fig];

else
    error('taskType is neither categorical nor coordinate');
end
