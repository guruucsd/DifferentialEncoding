function [avg_mean, std_mean, std_std, wts_mean, p] = sigma_vs_crossover(varargin)

  if ~exist('guru_popopt','file'), addpath(genpath('../../code')); end;
  [sigmas, varargin] = guru_popopt(varargin, 'Sigmas', [1 2:2:10]);%8 2 1/2 1/8 1/16 1/32];
  [cpi,    varargin] = guru_popopt(varargin, 'cpi',    6*[0.5:0.1:2]);%8 2 1/2 1/8 1/16 1/32];

  args  = { 
    'seed', 1, ...
    'w_mode', 'posmean', ...  % how to sample weights
    'a_mode', 'mean', ...  % how to compute output stats.
    'cpi',  cpi, ...
    'sz', [34, 25], ...  % size of image (square)
    'nConns', 25, ... % number of connections
    'distn', 'norme2', ...
    'nsamps', 5, ...  % 
    'nbatches', 5 ...  % 
    'img2pol', false, ...  % whether to stretch cartesian image via retinotopy
    'disp', [11], ...  % plots to show
    varargin{:} ...
  };


  %% Collect raw data
  for si=1:length(sigmas)
    fprintf('Processing sigma=%.2f...\n', sigmas(si));

    [am,sm,ss,wm,pt,ft] = nn_2layer_processor( ...
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
    f(si) = ft;
    wts_mean(si,:,:) = wm;
    p(end+1)=pt;
  end;
  
  %% Analyze raw data for crossover
  scaling = max(std_mean(:)); % Rescale over all sigmas, such that the scale of response isn't a factor
  numSigmas = size(std_mean, 1);
  crossover_cpi = zeros(numSigmas * (numSigmas-1), 1);
  sigma_pairs = zeros(numSigmas * (numSigmas-1), 2);
  counter = 1;
  for ii=1:numSigmas
  	for ij=1:numSigmas
      if ij == ii, continue; end

      ratios = std_mean(ii,:) ./ std_mean(ij,:); % Check when ratio goes over 1
      if (ratios(1) > 1)  % detect from high to low crossing
        compareFn = @(idx) ratios(idx) >= 1;
      else  % detect low to high crossing
        compareFn = @(idx) ratios(idx) <= 1;
      end;
      
      % Search for crossover point
      si = 2;
      while compareFn(si)
        si = si+1;
        if si > length(ratios)  % failure
          si = 1;
          break;
        end                
      end
      
      if si ~= 1 %this means there was a crossover
        crossover_cpi(counter) = cpi(si);
      %else
      %  crossover_cpi(counter) = nan;
      end
      sigma_pairs(counter, :) = [sigmas(ii), sigmas(ij)];
      counter = counter + 1;
    end
  end 
  
  
  %% Plot data
  
  % Generate plot labels
  lbls = cell(size(p));
  for pi=1:length(p)
      lbls{pi} = sprintf( ...
        'd_{center}=%.1f%% (%.1fpx); d_{nn} = %.1f%% (%.1fpx)', ...
        100 * p(pi).avg_dist / p(1).sz(1), ...
        p(pi).avg_dist, ...
        100 * mean(p(pi).neighbor_dist / p(1).sz(1)), ...
        mean(p(pi).neighbor_dist) ...
      );
  end;
  
  % Generate legend labels
  C{numSigmas, 1} = {};
  for si=1:numSigmas
     C{si} = sprintf('Sigma 1 = %d', sigmas(si)); 
  end
  
  % Massage data for plotting
  start = 1;
  sp = zeros(numSigmas, numSigmas-1);
  cc = zeros(numSigmas, numSigmas-1);
  for si=1:numSigmas
    sp(si, :) = sigma_pairs(start:start+numSigmas-2, 2);
    cc(si, :) = crossover_cpi(start:start+numSigmas-2);

    start = start + numSigmas -1;   
    fprintf('start = %d', start);
  end

  % Do the actual plotting
  figure;
  plot(sp', cc') %change to scatter if desired
  
  [hleg1, ~] = legend(C);
  set(hleg1, 'fontsize', 15);
  xlabel('Sigma 2');
  ylabel('Crossover frequency (CPI)');


function [avg_mean, std_mean, std_std, wts_mean, p, f] = nn_2layer_processor(varargin)
  
  [raw_avg, raw_std, ~, raw_wts, p] = nn_2layer(varargin{:});

  avg_mean = mean(raw_avg,1);  % mean of means
  std_mean = mean(raw_std,1);  % mean of standard deviations
  std_std  = std(raw_std,[],1)/sqrt(size(raw_std,1));
  wts_mean = squeeze(mean(raw_wts,1));

  % Calculate average distance
  dist_fn = zeros(size(wts_mean));
  for x=1:size(dist_fn,2), for y=1:size(dist_fn,1), dist_fn(y,x) = sqrt((x-(size(dist_fn,2)+1)/2).^2 + (y-(size(dist_fn,1)+1)/2).^2); end; end;
  p.avg_dist = dist_fn(:)' * (wts_mean(:)/sum(wts_mean(:)));

  % Calculate nearest-neighbor distance
  p.neighbor_dist = zeros(size(raw_wts,1), 1);
  for mi=1:size(raw_wts,1)
    p.neighbor_dist(mi) = calc_neighbor_dist(squeeze(raw_wts(mi,:,:))~=0);
  end;


  if ismember(13, p.disp)
      f = figure; imagesc(wts_mean); colorbar;
      title(sprintf('\\sigma=%.2fpx; d_{cent}=%.2fpx; d_{nn}=%.2f', p.Sigma(1), p.avg_dist, mean(p.neighbor_dist)), 'FontSize', 16);
  else
      f = NaN;
  end;




