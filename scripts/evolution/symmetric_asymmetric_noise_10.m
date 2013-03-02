clear globals variables;

net = common_args();

net.sets.dataset     = 'symmetric_asymmetric';
net.sets.axon_noise  = 1E-3;
net.sets.ncc         = 2;
net.sets.nhidden_per = 10;

looper(net);

