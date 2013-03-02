clear globals variables;


for axon_noise = [0 1E-3]
  for dataset = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'}
  
    net = common_args();
    net.sets.dataset     = dataset{1};
    net.sets.axon_noise  = axon_noise;
    net.sets.ncc         = 2;
    net.sets.nhidden_per = 10;
    net.sets.n_nets      = 1;
    
    for rseed=(288+[1:10])
      nets.sets.rseed = rseed;
      looper(net);
    end;
  end;
end;


