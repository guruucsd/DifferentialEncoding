clear globals variables;

if ~exist('r_looper','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;

chunk_size = guru_iff(exist('matlabpool','file'), matlabpool('size'), 1);

for rseed=(289-1+[1:chunk_size:10])
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
    
    r_looper(net, chunk_size)
end;
end;
end;
end;


  % Make into one giant cache
  cache_dir         = guru_fileparts(fileparts(net.sets.dirname), 'name');
  cache_file        = fullfile(cache_dir, [mfilename '.mat']);
  [~,~,~,~,folders] = collect_data_looped( cache_dir );
  
  make_cache_file(folders, cache_file);
