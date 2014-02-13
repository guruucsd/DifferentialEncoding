clear all variables; clear all globals;
[args,opts]  = lsb_args()

% Run sergent task by training on all images
[trn.left,  tst.left]  = de_SimulatorUber('uber/original', 'brady_etal_2005/orig/recog', {opts{:}, 'chimeric-left'}, args);
[trn.right, tst.right] = de_SimulatorUber('uber/original', 'brady_etal_2005/orig/recog', {opts{:}, 'chimeric-right'}, args);

