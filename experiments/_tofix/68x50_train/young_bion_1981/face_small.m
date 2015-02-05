% Left-side-bias on small (34x25) images
clear all variables; clear all globals;
[args,opt] = face_args();

% This will make the datasets
fprintf('Making datasets...\n');
[mSets, models, stats] = de_Simulator('young_bion_1981', 'orig', 'recog', {opt{:}}, args{:});
