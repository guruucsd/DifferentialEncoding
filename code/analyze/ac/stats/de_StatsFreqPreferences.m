function [stats] = de_StatsFreqPreferences(mss, varargin)
%
% Returns the distribution of weights and connections over all models within each sigma

  % Retrieve settings
  mSets = mss{end}(end);
  opt = {mSets.data.train.opt, varargin{:}};
  n_phases = guru_getopt(opt, 'nphases', 8);
  n_orients = guru_getopt(opt, 'nthetas', 8);
  n_freqs = guru_getopt(opt, 'nfreqs', 24);

  % Create a dataset to test network on.
  [~, dset] = de_MakeDataset('gratings', 'all', '', {mSets.data.train.opt{:}, ...
                             'nthetas', n_orients, 'nphases', n_phases, 'nfreqs', n_freqs, ...
                             'nInput', mSets.nInput}, false, false);  % don't visualize, but do force re-creation.
  dset = de_NormalizeDataset(dset, mSets);

  % Initialize variables
  n_sigmas = length(mss);
  stats.settings.dset = dset;

  for si=1:n_sigmas
    n_models = length(mss{si});

    for mi=1:n_models
      fprintf('%d ', mi)

      % Set up the network.
      model = de_LoadProps(mss{si}(mi), 'ac', 'Weights');

      % Run the network; huo==hidden unit output
      [~,~,huo] = guru_nnExec(model.ac, dset.X, dset.X(1:end-1, :));  % uses xfer fn
      clear('model');

      prop_lens = [n_freqs, n_orients, n_phases];
      resps = reshape(huo, [mSets.nHidden, prop_lens]);
      props = {'freq', 'orient', 'phase'};  % must follow order in resps, for permute below
      n_prop_names = length(props);

      % First, do a new analysis:
      % For a single property (e.g. frequency), see the
      % mean and std for response of each neuron within
      % variations of other properties while that one stays the same.
      for pi=1:n_prop_names
        prop = props{pi};
        n_prop_vals = eval(['n_' prop 's']);

        % Initialize storage
        if mi == 1  % on each loop through models
          if si == 1
            stats.(prop).mean = cell(n_sigmas, 1);
            stats.(prop).std = cell(n_sigmas, 1);
            if strcmp(prop, 'freq') % This code is used for sigma vs xover computations
                stats.(prop).std_mean = zeros(n_sigmas, n_freqs);
                stats.(prop).std_ste = zeros(n_sigmas, n_freqs);
                stats.(prop).xover = nan(n_sigmas, n_sigmas); %crossover freqs
                stats.(prop).spairs = nan(n_sigmas, n_sigmas, 2); %sigma pairs
            end
          end;  % initialize to nan, to easily check if everything has been filled.
          stats.(prop).mean{si}  = nan(n_models, mSets.nHidden, n_prop_vals);
          stats.(prop).std{si}  = nan(n_models, mSets.nHidden, n_prop_vals);
        end;

        % average over the other two properties.
        n_other_two = prod(prop_lens) / n_prop_vals;
        permute_idx = [1 (1+[pi setdiff(1:n_prop_names, pi)])];
        resps_by_prop = permute(resps, permute_idx);
        resps_by_prop = reshape(resps_by_prop, [mSets.nHidden, n_prop_vals, n_other_two]);

        % Just make sure that this funky indexing worked...
        lbls_by_prop = reshape(dset.XLAB, prop_lens);
        lbls_by_prop = permute(lbls_by_prop, permute_idx(2:end) - 1);
        lbls_by_prop = reshape(lbls_by_prop, [n_prop_vals, n_other_two]);
        prop_vals = dset.([prop 's']);
        guru_assert( ...
          ~isempty(strfind(lbls_by_prop{1,end}, sprintf('%f', prop_vals(1)))), ...
          'Messed up permute indexing :(' ...
        );

        % Note the "abs" here for mean; if I average all responses,
        % since they can be negative, I generally get zero.
        % So, average the response magnitudes - more interesting.
        stats.(prop).mean{si}(mi,:,:) = mean(abs(resps_by_prop), 3);
        stats.(prop).std{si}(mi,:,:) = std(resps_by_prop, [], 3);
      end;

    end;
    % Now, do the analysis as done in the `recfields` scripts.
    
    %Take raw stds and average over all units (see nn_2layer_processor)
    raw_std = stats.freq.std{si};
    %First, combine first 2 dimensions (models x hidden units)
    raw_std = reshape(raw_std, [size(raw_std, 1)*size(raw_std, 2), size(raw_std, 3)]);
    sm = mean(raw_std,1); %avg over each unit, like in recfields
    ss  = std(raw_std,[],1)/sqrt(size(raw_std,1)); %stick to naming convention

    stats.('freq').std_mean(si, :) = sm;
    stats.('freq').std_ste(si, :) = ss; %std_err of std_dev
    
  end
    
  % To aid in readability and stay consistent w/ conventions in
  % sigma_vs_crossover, define a few variables.
  std_mean = stats.('freq').std_mean; % aids in readability, stay consistent w/ sigma_vs_crossover
  numSigmas = n_sigmas;
  cpi = dset.freqs * max(dset.nInput);
  stats.freq.cpi = cpi; %will need this later
  
  for ii=1:numSigmas
    for ij=(ii+1):numSigmas
      % which direction should we be searching for cross-overs?
      ratios = std_mean(ii,:) ./ std_mean(ij,:); % Check when ratio goes over 1
  
      % -1 means 1.0+ => 0.9-
      % add 1, as diff has n-1 elements
      xoverPts = 1 + find(diff(ratios > 1) == -1);

      % Do nothing for zero.
      if length(xoverPts) == 1
        si = xoverPts;
      elseif length(xoverPts) > 1
        % multiple points, keep the one closest to the middle
        % of the range of frequencies. TOTALLY AD-HOC
        xoverPts
        [~, minIdx] = min(abs(xoverPts - length(ratios) / 2));
        si = xoverPts(minIdx);
      else
        continue; 
        % No points. Look for a trend.
        % [~, si] = min(ratios(2:end));  % si represents AFTER the crossing.
      end;

      % Now we have the crossover point (between si-1 and si);
      % do linear interpolation to estimate the crossover.
      pctOfUnitMoved = (ratios(si-1) - 1) / -diff(ratios(si-1:si));
      cpiMoved = diff(cpi(si-1:si)) * pctOfUnitMoved;
      
      % save results
      stats.('freq').xover(ii, ij) = cpi(si-1) + cpiMoved;
      stats.('freq').spairs(ii, ij, :) = ...
          [unique([mss{ii}.sigma]), unique([mss{ij}.sigma])];
    end
  end

