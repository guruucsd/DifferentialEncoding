% Left-side-bias on small (34x25) images

[args] = lsb_args();

% This will make the datasets
fprintf('Making datasets...');
[mSets, models, stats] = de_Simulator('hsiao_etal_2008', 'orig', 'recog', {'small'}, args{:});
