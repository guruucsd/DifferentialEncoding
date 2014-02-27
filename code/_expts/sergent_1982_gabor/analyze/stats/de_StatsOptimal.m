function [stats_opt] = de_StatsOptimal(huencs,dset)
%
% Compares to the optimal

  %
  nStims = size(dset.X,2);

  % Create local & global ideal
  corrs_ideal_global = -1*ones(nStims);
  corrs_ideal_local  = -1*ones(nStims);

  for stim={'T1','T2','D1','D2'}
    global_idx = find(guru_findstr(dset.ST, stim{1}, 1)==1);
    corrs_ideal_global(global_idx,global_idx) = 1;

    local_idx = find(guru_findstr(dset.ST, stim{1}, 3)==1);
    corrs_ideal_local(local_idx,local_idx) = 1;
  end;

  % Compute comparson to ideal for each case
  comparison_ideal_global = cell(size(huencs));
  comparison_ideal_local  = cell(size(huencs));

  for i=1:length(huencs)
    comparison_ideal_global{i} = zeros([size(huencs{i},1) 1]);
    comparison_ideal_local{i} = zeros([size(huencs{i},1) 1]);

    for j=1:size(huencs{i},1)%#models
      huenc = reshape(huencs{i}(j,:,:), [size(huencs{i},2), size(huencs{i},3)]);

      % Correlate hidden unit activations
      corrs = zeros(nStims);
      for w1=1:nStims
        for w2=1:nStims
          corrs( w1,w2 ) = corr( huenc(:, w1), huenc(:,w2) );
        end;
      end;

      % Compare with ideal
      comparison_ideal_global{i}(j) = corr( corrs(:), corrs_ideal_global(:) );
      comparison_ideal_local{i}(j)  = corr( corrs(:), corrs_ideal_local(:) );
    end;
  end;

  stats_opt.global = comparison_ideal_global;
  stats_opt.local  = comparison_ideal_local;

