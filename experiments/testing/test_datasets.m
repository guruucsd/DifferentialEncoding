script_dir = fileparts(which(mfilename));
code_dir = fullfile(script_dir, '..', '..', 'code');
addpath(genpath(code_dir));

% de_MakeDataset('han_etal_2003', 'cb', 'sergent', {'large'}, true, true);

% de_MakeDataset('okubo_michimata_2002', 'dots-cb', 'categorical', {'medium'}, true, true);
% de_MakeDataset('okubo_michimata_2002', 'dots', 'coordinate', {'medium'}, true, true);

% de_MakeDataset('slotnick_etal_2001', 'blob-dot', 'categorical', {'medium'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'blob-dot', 'coordinate', {'medium'}, true, true);
 de_MakeDataset('slotnick_etal_2001', 'paired-squares', 'coordinate', {'small'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'plus-minus', 'categorical', {'small'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'plus-minus', 'coordinate', {'small'}, true, true);
