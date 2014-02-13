function [figs] = de_PlotHLOptimal(huencs,dset)
%
% huencs: [nModels] x [nHidden] x [nStim]
%
% Compares to the optimal

  %
  nModels = size(huencs,1);
  nHidden = size(huencs,2);
  nStims  = size(huencs,3);
  
  % Create local & global ideal
  corrs_ideal_global = -1*ones(nStims);
  corrs_ideal_local  = -1*ones(nStims);
  
  for stim={'T1','T2','D1','D2'}
    global_idx = find(guru_findstr(dset.ST, stim{1}, 1)==1);
    corrs_ideal_global(global_idx,global_idx) = 1;
    
    local_idx = find(guru_findstr(dset.ST, stim{1}, 3)==1);
    corrs_ideal_local(local_idx,local_idx) = 1;
  end;

  % Create matrix for actual data

  % Plot ideal
  %   
  % Compute comparson to ideal for each case
  
  corrs = zeros(nModels, nStims, nStims);
  comparison_ideal_global = zeros(nModels,1);
  comparison_ideal_local  = zeros(nModels,1);

  % For each model instance and stimulus,
  %   correlate the hidden unit activities
  %  
  for i=1:nModels
    huenc = reshape(huencs(i,:,:), [nHidden, nStims]);

    % Correlate hidden unit activations
    for w1=1:nStims
      for w2=1:nStims
        corrs(i,w1,w2 ) = corr( huenc(:, w1), huenc(:,w2) );
      end;
    end;

    % Compare with ideal
    comparison_ideal_global(i) = corr( reshape(corrs(i,:,:), size(corrs_ideal_global(:))), corrs_ideal_global(:) ); 
    comparison_ideal_local(i)  = corr( reshape(corrs(i,:,:), size(corrs_ideal_local(:))), corrs_ideal_local(:) ); 
  end;

  % So now we do four plots
  figs(1).name = 'optimal-data';   figs(1).handle = figure; 
  imagesc(squeeze(mean(corrs,1)), [-1 1]);
  set(gca, 'xtick', [1:length(dset.XLAB)], 'xticklabel', dset.XLAB);
  set(gca, 'ytick', [1:length(dset.XLAB)], 'yticklabel', dset.XLAB);
  
  figs(2).name = 'optimal-global';   figs(2).handle = figure; 
  imagesc(corrs_ideal_global, [-1 1]);
  set(gca, 'xtick', [1:length(dset.XLAB)], 'xticklabel', dset.XLAB);
  set(gca, 'ytick', [1:length(dset.XLAB)], 'yticklabel', dset.XLAB);
  
  figs(3).name = 'optimal-local';   figs(3).handle = figure; 
  imagesc(corrs_ideal_local, [-1 1]); colorbar;
  set(gca, 'xtick', [1:length(dset.XLAB)], 'xticklabel', dset.XLAB);
  set(gca, 'ytick', [1:length(dset.XLAB)], 'yticklabel', dset.XLAB);

%  subplot(4,1,1); imagesc(, [0 1]); %ideal global
%  subplot(4,1,2); imagesc(, [0 1]); %ideal global
%  subplot(4,2,1); imagesc(, [0 1]); %ideal global
%  subplot(4,2,2); imagesc(, [0 1]); %ideal global
%  stats_opt.global = comparison_ideal_global;
%  stats_opt.local  = comparison_ideal_local;
    
