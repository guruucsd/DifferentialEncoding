%I want to add the directory of the experiment size (e.g.
%/DifferentialEncoding/experiments/68x50) to the path, so that the
%arguments file works correctly. So, get the full path name of the script
%and find the parent directory of that.
%
%This prevents MATLAB from loading arg files in experiments/34x25/ when the
%experiment uses 68x50 stimuli.

fname = mfilename('fullpath');
[dir, ~, ~] = fileparts(fname); %find directory of script
[dir, ~, ~] = fileparts(fname); %find parent directory: should be 68x50 or 34x25
addpath(dir);

[args, opts]  = uber_slotnick_args('p.dropout', 0.7);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/blob-dot/categorical', opts, args);
