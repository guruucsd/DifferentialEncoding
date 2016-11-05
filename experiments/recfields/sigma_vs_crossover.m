function [avg_mean, std_mean, std_std, wts_mean, p] = sigma_vs_crossover(varargin)

  if ~exist('guru_popopt','file'), addpath(genpath('../../code')); end;

  old_sz = [20 20];
  [sigmas, varargin] = guru_popopt(varargin, 'Sigmas', [1 2:2:12]);%8 2 1/2 1/8 1/16 1/32];
  [new_sz, varargin] = guru_popopt(varargin, 'sz',    [20, 20]);

  [nConns, varargin] = guru_popopt(varargin, 'nConns', round(36 * prod(new_sz) / prod(old_sz)));
  [cpi,    varargin] = guru_popopt(varargin, 'cpi',    [0:0.25:6]);
  [seed,   varargin] = guru_popopt(varargin, 'seed',   1);

  % Reproducible science :)
  rand('seed', seed);
  randn('seed', seed);

  args  = {
    'seed', seed, ...
    'wMode', 'posmean', ...  % how to sample weights
    'aMode', 'mean', ...  % how to compute output stats.
    'cpi',  cpi, ...
    'sz', new_sz, ...  % size of image (square)
    'nConns', nConns, ... % number of connections
    'distn', 'normem2', ...
    'nSamps', 5, ...  %
    'nBatches', 5 ...  %
    'img2pol', false, ...  % whether to stretch cartesian image via retinotopy
    'disp', [11], ...  % plots to show
    varargin{:} ...
  };


  %% Collect raw data
  for si=1:length(sigmas)
    fprintf('Processing sigma = %.2f...\n', sigmas(si));

    [am,sm,ss,wm,pt] = nn_2layer_processor( ...
        args{:}, ...
       'Sigma', sigmas(si)*[1 0;0 1] ... % circular gaussian
    );

    if (si==1)
      % Initialize outputs
      freqs = pt.freqs;

      avg_mean = zeros(length(sigmas), length(freqs));
      std_mean = zeros(length(sigmas), length(freqs));
      std_std  = zeros(length(sigmas), length(freqs));
      f        = zeros(length(sigmas),1);
      wts_mean = zeros(length(sigmas), size(wm,1), size(wm,2));

      p=pt(1:0);
    end;

    avg_mean(si, :) = am;
    std_mean(si,:) = sm;
    std_std(si, :) = ss;
    wts_mean(si,:,:) = wm;
    p(end+1)=pt;
  end;


  %% Analyze raw data for crossover
  numSigmas = size(std_mean, 1);
  crossover_cpi = nan(numSigmas, numSigmas);
  sigma_pairs = nan(numSigmas, numSigmas, 2);
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
      crossover_cpi(ii, ij) = cpi(si-1) + cpiMoved;

      sigma_pairs(ii, ij, :) = [sigmas(ii), sigmas(ij)];
    end
  end


  %% Plot data

  % Generate legend labels
  C{numSigmas, 1} = {};
  for si=1:numSigmas
     C{si} = sprintf('\\sigma = %d', sigmas(si));
  end

  % Massage data for plotting
  cc = crossover_cpi'
  sp = repmat(sigmas, [numSigmas 1]);

  % Do the actual plotting
  figure('Position', [ 0 0 1024 768]);
  plot(sp', cc', 'o-', 'MarkerSize', 5, 'LineWidth', 5) %change to scatter if desired
  title(sprintf('Crossover for %d x %d image, %d connections, cpi(0)=%.2f.', ...
                p(1).sz, p(1).nConns, p(1).cpi(1)), ...
        'FontSize', 20);
  legend(C, 'Location', 'SouthWest', 'FontSize', 14);
  xlabel('Sigma 2', 'FontSize', 16);
  ylabel('Crossover frequency (CPI)', 'FontSize', 16);

  if ismember(11, pt.disp)
      scaling = max(abs(std_mean(:))); % Rescale over all sigmas, such that the scale of response isn't a factor
      max_std = repmat(max(abs(std_mean),[],2), [1 length(freqs)]); % can normalize each sigma's response so that it's peak is 1
      %max_std = avg_mean;
      ns_mean = std_mean./max_std;
      ns_std  = std_std./sqrt(max_std);

      lbls = cell(size(p));
      for pi=1:length(p)
          lbls{pi} = sprintf('sigma = %.2f', p(pi).Sigma(1));
      end;

      % Plots the mean (across all units) of the standard deviation of each
      % units' response to different frequency gratings (frequency, phase,
      % orientation)

      colors = @(si) (reshape(repmat(numel(sigmas)-si(:), [1 3])/numel(sigmas) * 1 .* repmat([1 0 0],[numel(si) 1]),[numel(si) 3]));

      figure('position', [0, 0, 768, 768]);
      hold on;
      %plot(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean/scaling)', 'LineWidth', 2);
      %errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean)'/scaling, std_std'/scaling);
      for si=1:length(sigmas)
        plot(cpi, std_mean(si,:)/scaling, '*-', 'Color', colors(si), 'LineWidth', 3, 'MarkerSize', 5);
      end;
      for si=1:length(sigmas)
        errorbar(cpi, std_mean(si,:)/scaling, std_std(si,:)/scaling, 'Color', colors(si));
      end;
      set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
      set(gca, 'FontSize', 16);
      xlabel('frequency (cycles per image)');
      ylabel('output activity (linear xfer fn)');
      legend(lbls, 'Location', 'best', 'FontSize',16);
      title('Non-normalized std (divided by global mean)');

  end;

function [avg_mean, std_mean, std_std, wts_mean, p] = nn_2layer_processor(varargin)

  [raw_avg, raw_std, ~, raw_wts, p] = nn_2layer(varargin{:});

  avg_mean = mean(raw_avg,1);  % mean of means
  std_mean = mean(raw_std,1);  % mean of standard deviations
  std_std  = std(raw_std,[],1)/sqrt(size(raw_std,1));
  wts_mean = squeeze(mean(raw_wts,1));


