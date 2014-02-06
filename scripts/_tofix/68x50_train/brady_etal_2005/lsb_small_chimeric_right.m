% Left-side-bias on small (34x25) images

[args,opt] = lsb_args();

% This will make the datasets
fprintf('Making datasets...');
[mSets, models, stats] = de_Simulator('brady_etal_2005', 'orig', 'recog', {opt{:},'chimeric-right'}, args{:});
