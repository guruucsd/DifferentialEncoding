%Add current directory to top of path, so the correct uber_slotnick_args is 
%referenced. This only works if ubser_slotnic_args and this file are in
%the same directory

fname = mfilename('fullpath');
[dir, ~, ~] = fileparts(fname);
addpath(dir);

[args, opts]  = uber_slotnick_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/blob-dot/categorical', opts, args);
