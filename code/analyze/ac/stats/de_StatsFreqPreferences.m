function [stats] = de_StatsFreqPreferences(mss, varargin)
%
% Returns the distribution of weights and connections over all models within each sigma

  mSets = mss{end}(end);

  p = struct( 'a_mode', 'mean', ... % activation mode
              'nphases', 8, ...
              'norients', 8, ...
              'niters', 1, ...  % # times to feed output back to input
              'cpi', 3*[0.25 0.5 1 1.5 2 3 4] ...    %freqs = 0.015 * [ 6 9 12 15];
            );
  p        = guru_stampProps(p, varargin{:});

  % Set param values that are dependent on other param values
  if (~isfield(p, 'lambda')), p.lambda = prod(mSets.nInput)/mSets.nConns; end;

  % Create the stimuli
  X = zeros(prod(mSets.nInput)+1, length(p.cpi)*p.norients*p.nphases);
  X(end,:) = mSets.data.train.bias;
  for fi=1:length(p.cpi)

    for oi = 1:p.norients
      orient = pi*oi/p.norients;
      for phsi=1:p.nphases
        phase = 2*pi*phsi/p.nphases;

        % Create the input
        x_train = mSets.data.train.X(1:end-1,:);
        freq = p.cpi(fi);
        x = mfe_grating2d( p.cpi(fi), phase, orient, 0.5, mSets.nInput(1), mSets.nInput(2));
        x_norm = x/sum(x(:));
        %x_mean = x_norm - mean(x_norm(:)) + mean(x_train(:));
        %x_z    = x_mean/std(x_mean(:))*std(x_train(:));
        x_z = x_norm;

        X(1:end-1,(fi-1) * p.norients * p.nphases + (oi-1) * p.nphases + phsi) = x_z(:);
        guru_assert(~any(isnan(x_z(:))));
      end;
    end;
  end;

  [~, train] = de_MakeDataset('gratings', 'all', '', {mSets.data.train.opt{:}, 'nthetas', p.norients, 'nphases', p.nphases, 'cycles', p.cpi});
  X2 = zeros(prod(mSets.nInput)+1, length(p.cpi)*p.norients*p.nphases);
  X2(end, :) = mSets.data.train.X(end,1); %bias term
  X2(1:end-1, :) = 0.5 + 0.5 * train.X(:, :);
  x2_norm = X2/sum(X2(:));
  x2_mean = x2_norm - mean(x2_norm(:));
  x2_z    = x2_mean/std(x2_mean(:)) * std(mSets.data.train.X(:));
  X2 = x2_z;
  X=X2;

  % Initialize variables
  bestofall= cell(length(mss),1);
  avg_resp = cell(length(mss),1);
  std_resp = cell(length(mss),1);
  resps    = cell(length(mss),1);

  for si=1:length(mss)
    bestofall{si} = zeros(length(mss{si}),1);
    avg_resp{si}  = zeros(length(mss{si}), mSets.nHidden, length(p.cpi));
    std_resp{si}  = zeros(length(mss{si}), mSets.nHidden, length(p.cpi));
    resps{si}     = zeros(length(mss{si}), mSets.nHidden, length(p.cpi), p.norients, p.nphases);

    for mi=1:length(mss{si})
      m = de_LoadProps(mss{si}(mi), 'ac', 'Weights');
      m.ac.Weights(m.ac.Weights ~= 0) = abs(m.ac.Weights(m.ac.Weights ~= 0));%      0.01;
      m.ac.XferFn = 1;

      %
      best_vals = -inf*ones(size(p.cpi));
      best_params = zeros(length(p.cpi), 3);
      best_x = zeros(length(p.cpi), prod(mSets.nInput));

      % Run the network
      [~,~,huo] = guru_nnExec(m.ac, X, X(1:end-1,:));
      resps{si}(mi,:,:,:,:) = reshape(huo, [mSets.nHidden, length(p.cpi) p.norients, p.nphases]);

      % normalize
      resps_by_freq = reshape(resps{si}(mi,:,:,:,:), [mSets.nHidden, length(p.cpi) p.norients * p.nphases]);
      resps_by_freq_norm = resps_by_freq;%/mean(abs(resps_by_freq(:)));
      fprintf('%d ', mi)
      switch p.a_mode
          case 'max'
              [~,bestofall(mi)] = max(best_vals);

          case {'mean','total'}
              avg_resp{si}(mi,:,:) = mean(resps_by_freq_norm,3);
              std_resp{si}(mi,:,:) = std(resps_by_freq_norm,[],3);
              %best_vals = avg_resp{si}(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std'}
              avg_resp{si}(mi,:,:) = mean(resps_by_freq_norm,3);
              std_resp{si}(mi,:,:) = std(resps_by_freq_norm,[],3);
              %best_vals = std_resp{si}(mi,:);
              %[~,bestofall{si}(mi)] = max(std_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'mean_lgs','avg_lgs', 'total_lgs'} % run through logistic
              resps = tanh(p.lambda * resps);
              resps_by_freq = reshape(resps, [length(p.cpi) p.norients * p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = avg_resp{si}(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std_lgs','range_lgs'} % run through logistic
              resps = 1/(1+exp(-p.lambda * resps));
              resps_by_freq = reshape(resps, [length(p.cpi) p.norients * p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = std_resp(mi,:);
              [~,bestofall{si}(mi)] = max(std_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'mean_sqd','avg_sqd', 'total_sqd'}
              resps = resps.^2;
              resps_by_freq = reshape(resps, [length(p.cpi) p.norients * p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = avg_resp(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std_sqd','range_sqd'}
              resps = resps.^2;
              resps_by_freq = reshape(resps, [length(p.cpi) p.norients * p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = std_resp(mi,:);
              [~,bestofall{si}(mi)] = max(std_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case 'range',
              rng  = max(alld') - min(alld');
              [~,bestofall(mi)] = max(rng);

          otherwise, error('%s nyi', p.a_mode);
      end;
    end;
  end;

  stats.avg_resp = avg_resp;
  stats.std_resp = std_resp;
  stats.settings = p;
 