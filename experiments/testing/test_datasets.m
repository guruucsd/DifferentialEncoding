clear all; clear all globals; close all

script_dir = fileparts(which(mfilename));
code_dir = fullfile(script_dir, '..', '..', 'code');
addpath(genpath(code_dir));

% de_MakeDataset('christman_etal_1991', 'low_freq', 'recog', {'small'}, true, true);
% de_MakeDataset('christman_etal_1991', 'high_freq', 'recog', {'small'}, true, true);
% de_MakeDataset('christman_etal_1991', 'low_freq', 'recog', {'medium'}, true, true);
% de_MakeDataset('christman_etal_1991', 'high_freq', 'recog', {'medium'}, true, true);
% de_MakeDataset('christman_etal_1991', 'low_freq', 'recog', {'large'}, true, true);
% de_MakeDataset('christman_etal_1991', 'high_freq', 'recog', {'large'}, true, true);

% de_MakeDataset('han_etal_2003', 'de', 'sergent', {'large'}, true, true);
% de_MakeDataset('han_etal_2003', 'cb', 'sergent', {'large'}, true, true);

% de_MakeDataset('jonsson_hellige_1986', 'HMTVWXY', 'samediff', {'small'}, true, true);

de_MakeDataset('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {'small', 'nphases', 16, 'nthetas', 1}, true, true);
% de_MakeDataset('kitterle_etal_1992', 'sf_mixed', 'recog_type', {'small'}, true, true);

% de_MakeDataset('okubo_michimata_2002', 'dots-cb', 'categorical', {'medium'}, true, true);
% de_MakeDataset('okubo_michimata_2002', 'dots', 'coordinate', {'medium'}, true, true);

% de_MakeDataset('slotnick_etal_2001', 'blob-dot', 'categorical', {'medium'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'blob-dot', 'coordinate', {'medium'}, true, true);
  de_MakeDataset('slotnick_etal_2001', 'paired-squares', 'coordinate', {'small'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'paired-squares', 'coordinate', {'medium'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'plus-minus', 'categorical', {'small'}, true, true);
% de_MakeDataset('slotnick_etal_2001', 'plus-minus', 'coordinate', {'small'}, true, true);

% de_MakeDataset('text', 'kangaroos', '', {'large', 'skip', 1000}, true, true);

% de_MakeDataset('vanhateren', '25', '', {'small'}, true, true);

% de_MakeDataset('young_bion_1981', 'orig', 'recog', {'small'}, true, true);

