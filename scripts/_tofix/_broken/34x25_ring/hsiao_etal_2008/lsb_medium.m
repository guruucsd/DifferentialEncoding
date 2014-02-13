% Left-side-bias on small (34x25) images

[args] = lsb_args('ac.MaxIterations', 501);

ds = 'medium'; %dataset size

% This will make the datasets.  2 are made

fprintf('Making datasets...');
[mSets, models, stats] = de_Simulator('hsiao_etal_2008', 'orig', 'recog', {ds}, args{:});
