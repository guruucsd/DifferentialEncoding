clear globals variables;

net = common_args();

net.sets.dataset     = 'asymmetric_symmetric';
net.sets.axon_noise  = 0;
net.sets.ncc         = 3;
net.sets.nhidden_per = 15;

looper(net);

