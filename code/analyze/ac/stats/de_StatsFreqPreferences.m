function [stats] = de_StatsFreqPreferences(mss, varargin)
%
% Returns the distribution of weights and connections over all models within each sigma

  % Retrieve settings
  mSets = mss{end}(end);
  opt = {mSets.data.train.opt, varargin{:}};
  n_phases = guru_getopt(opt, 'nphases', 8);
  n_orients = guru_getopt(opt, 'nthetas', 8);
  n_freqs = guru_getopt(opt, 'nfreqs', 8);

  % Create a dataset to test network on.
  [~, dset] = de_MakeDataset('gratings', 'all', '', {mSets.data.train.opt{:}, ...
                             'nthetas', n_orients, 'nphases', n_phases, 'nfreqs', n_freqs, ...
                             'nInput', mSets.nInput}, false, false);  % don't visualize, but do force re-creation.
  mSets.ac.zscore = mSets.ac.zscore;
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

      % Now, do the analysis as done in the `recfields` scripts.


    end;
  end;

