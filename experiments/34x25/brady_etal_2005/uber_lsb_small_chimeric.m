error('Needs to be updated for latest code.');
[args,opts]  = lsb_args()

% Run sergent task by training on all images
[trn.left,  tst.left]  = de_SimulatorUber('vanhateren/250', 'brady_etal_2005/orig/recog', {opts{:}, 'chimeric-left'}, args);
[trn.right, tst.right] = de_SimulatorUber('vanhateren/250', 'brady_etal_2005/orig/recog', {opts{:}, 'chimeric-right'}, args);

