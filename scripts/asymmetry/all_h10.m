clear globals variables;

if ~exist('r_looper','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;

for rseed=(289-1+[1:10])
for ncc = [2 0]
for axon_noise = [0 1E-3]
  for dataset = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'}
  
    net = common_args();
    net.sets.dirname     = fullfile(net.sets.dirname, mfilename(), sprintf('%s_%s_n%d', dataset{1}, guru_iff(axon_noise==0, 'nonoise', 'noise'), ncc));

    net.sets.dataset     = dataset{1};
    net.sets.axon_noise  = axon_noise;

    net.sets.ncc         = ncc; 
    net.sets.nhidden_per = 10;
    
    net.sets.rseed = rseed;
    net.sets.n_nets = 1;
    
    r_looper(net);

end;
end;
end;
end;

