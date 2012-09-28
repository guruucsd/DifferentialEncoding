% Left-side-bias on small (34x25) images

[args] = face_args();

% This will make the datasets
fprintf('Making datasets...');
[mSets, models, stats] = de_Simulator('young_bion_1981', 'orig', 'recog', {'small'}, args{:});
