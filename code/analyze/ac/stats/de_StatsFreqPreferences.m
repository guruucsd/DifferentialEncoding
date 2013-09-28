function [stats] = de_StatsFreqPreferences(mss, varargin)
%
% Returns the distribution of weights and connections over all models within each sigma

  mSets = mss{end}(end);

  p = struct( 'a_mode', 'std', ... % activation mode
              'w_mode', 'posmean', ... % weight mode
              'nphases', 8, ...
              'norients', 8, ...
              'niters', 1, ...  % # times to feed output back to input
              'freqs', [ 0.0001 0.01 * [ 6 7.5 9 10.5] 0.1 0.5] ...    %freqs = 0.015 * [ 6 9 12 15];
            );
  p        = guru_stampProps(p, varargin{:});
  % Set param values that are dependent on other param values
  if (~isfield(p, 'lambda')), p.lambda = prod(mSets.nInput)/mSets.nConns; end;

  % Create the stimuli
  X = zeros(prod(mSets.nInput)+1, length(p.freqs)*p.norients*p.nphases);
  X(end,:) = mSets.data.train.bias;
  for fi=1:length(p.freqs)

    for oi = 1:p.norients
      orient = pi*oi/p.norients;
      for phsi=1:p.nphases
        phase = 2*pi*phsi/p.nphases;

        % Create the input
        x_train = mSets.data.train.X(1:end-1,:);
        x = 0.5+mfe_grating2d( p.freqs(fi), phase, orient, 0.5, mSets.nInput(1), mSets.nInput(2));
        x_norm = x/sum(x(:));
        x_mean = x_norm - mean(x_norm(:)) + mean(x_train(:));
        x_z    = x_mean/std(x_mean(:))*std(x_train(:));

        X(1:end-1,(fi-1)*p.norients*p.nphases + (oi-1)*p.nphases+phsi) = x_z(:);
        guru_assert(~any(isnan(x_z(:))));
      end;
    end;
  end;

  % Initialize variables
  bestofall= cell(length(mss),1);
  avg_resp = cell(length(mss),1);
  std_resp = cell(length(mss),1);
  resps    = cell(length(mss),1);

  for si=1:length(mss)
    bestofall{si} = zeros(length(mss{si}),1);
    avg_resp{si}  = zeros(length(mss{si}), mSets.nHidden, length(p.freqs));
    std_resp{si}  = zeros(length(mss{si}), mSets.nHidden, length(p.freqs));
    resps{si}     = zeros(length(mss{si}), mSets.nHidden, length(p.freqs),p.norients,p.nphases);
    
    for mi=1:length(mss{si})
      m = de_LoadProps(mss{si}(mi), 'ac', 'Weights');
      m.ac.Weights(m.ac.Weights ~= 0) = 0.01;
      m.ac.XferFn = 1;

      % Determine weights (abstract)
      %w     = zeros(mSets.nInput);%spatial map of weights;
      %inidx = 
      %switch (p.w_mode)
      %    case {'fixed'},    w(inidx) = ones(size(inidx));
      %    case {'posmean'},  w(inidx) = abs(randn(size(inidx)));
      %    case {'negmean'},  w(inidx) = -abs(randn(size(inidx)));
      %    case {'zeromean'}, w(inidx) = randn(size(inidx));
      %    case {'center-surround'} % weight is based on distance from center (both magnitude (gauss), and sign (mex-hat))
      %      dfromcent = sqrt(sum((X(inidx,:) - repmat(p.mu,[length(inidx) 1])).^2,2));
      %      w(inidx) = w_pdf(inidx) .* (1-2*(dfromcent > p.dfromcent));
      %    otherwise, error('unknown weight mode: %s', p.w_mode);
      %end;
      %w = w / sum(abs(w(:)));

      %
      best_vals = -inf*ones(size(p.freqs));
      best_params = zeros(length(p.freqs), 3);
      best_x = zeros(length(p.freqs), prod(mSets.nInput));

      % Run the network
      [~,~,huo] = guru_nnExec(m.ac, X, X(1:end-1,:));
      resps{si}(mi,:,:,:,:) = reshape(huo, [mSets.nHidden, length(p.freqs) p.norients, p.nphases]);

      % normalize
      resps_by_freq = reshape(resps{si}(mi,:,:,:,:), [mSets.nHidden, length(p.freqs) p.norients*p.nphases]);
      resps_by_freq_norm = resps_by_freq/mean(abs(resps_by_freq(:)));

      switch p.a_mode
          case 'max'
              [~,bestofall(mi)] = max(best_vals);

          case {'mean','total'}
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,3);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],3);
              %best_vals = avg_resp{si}(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std'}
              avg_resp{si}(mi,:,:) = mean(resps_by_freq_norm,3);
              std_resp{si}(mi,:,:) = std(resps_by_freq_norm,[],3);
              %best_vals = std_resp{si}(mi,:);
              %[~,bestofall{si}(mi)] = max(std_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'mean_lgs','avg_lgs', 'total_lgs'} % run through logistic
              resps = tanh(p.lambda*resps);
              resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = avg_resp{si}(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std_lgs','range_lgs'} % run through logistic
              resps = 1/(1+exp(-p.lambda*resps));
              resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = std_resp(mi,:);
              [~,bestofall{si}(mi)] = max(std_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'mean_sqd','avg_sqd', 'total_sqd'}
              resps = resps.^2;
              resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
              resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
              avg_resp{si}(mi,:) = mean(resps_by_freq_norm,2);
              std_resp{si}(mi,:) = std(resps_by_freq_norm,[],2);
              %best_vals = avg_resp(mi,:);
              [~,bestofall{si}(mi)] = max(avg_resp{si}(mi,:));%max(mean(mean(resps,3),2));

          case {'std_sqd','range_sqd'}
              resps = resps.^2;
              resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
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

  squeeze(mean(mean(std_resp{end},2),1)) - squeeze(mean(mean(std_resp{1},2),1))
  keyboard % implementation in-progress; should not be integrated into main branch!
