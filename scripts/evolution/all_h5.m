clear globals variables;

dirs = {};

for rseed=(289-1+[1:10])
for ncc = [2 0]
for axon_noise = [0 2E-3]
  for dataset = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'}
  
    net = common_args();

    net.sets.dataset     = dataset{1};
    net.sets.axon_noise  = axon_noise;

    net.sets.ncc         = ncc; 
    net.sets.nhidden_per = 5;
    
    net.sets.rseed = rseed;
    net.sets.n_nets = 1;
    
    full_dirname     = strrep(net.sets.dirname, mfilename, sprintf('%s_%s_%s_n%d', mfilename, dataset{1}, iff(axon_noise==0, 'nonoise', 'noise'), ncc));
    
    % Save the dirname
    [~,dirname]    = fileparts(full_dirname);
    if ~ismember(dirname, dirs)
      dirs{end+1} = dirname;
    end;

    % Run it
    looper(net);
end;
end;
end;
end;

dirs
cd ../../runs
make_cache(dirs, [mfilename '_cache_file']);