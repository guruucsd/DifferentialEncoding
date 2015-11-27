function figs = de_FigurizerCC(mSets, mss, stats)
%% Still needed:
% 1) Make the plots prettier. Currently plots have #s that overlap.
% 2) Implement code that generalizes based on the task (blob/dot vs paired
% squares etc)

ds = 'test';
taskTitle = guru_capitalizeStr(mSets.data.taskType);


left = stats.rej.cc.perf.(ds){1};
right = stats.rej.cc.perf.(ds){end};
rons = mSets.runs;
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

left_stderr = std(mean(left_results, 2)) / sqrt(size(left_results, 1));
right_stderr = std(mean(right_results, 2)) / sqrt(size(right_results, 1));

fig = de_CreateSlotnickFigure1([left_average right_average], [left_stderr right_stderr], taskTitle, rons);
figs = [fig];
