function [avg_mean, std_mean, std_std, wts_mean, p] = sigma_vs_crossover(varargin)

  if ~exist('guru_popopt','file'), addpath(genpath('../../code')); end;
  [sigmas, varargin] = guru_popopt(varargin, 'Sigmas', [2:2:10]);%8 2 1/2 1/8 1/16 1/32];
  [cpi,    varargin] = guru_popopt(varargin, 'cpi',    4*[0.5:0.1:2]);%8 2 1/2 1/8 1/16 1/32];

  rand('seed', 1);
  randn('seed', 1);
   
  args  = { 
    'seed', 1, ...
    'w_mode', 'posmean', ...  % how to sample weights
    'a_mode', 'mean', ...  % how to compute output stats.
    'cpi',  cpi, ...
    'sz', [20, 20], ...  % size of image (square)
    'nConns', 34, ... % number of connections
    'distn', 'norme2', ...
    'nsamps', 5, ...  % 
    'nbatches', 5 ...  % 
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
      density = pt.nConns / prod(pt.sz)
      
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
  crossover_cpi = nan(numSigmas * numSigmas, 1);
  sigma_pairs = nan(numSigmas * numSigmas, 2);
  counter = 1;
  for ii=1:numSigmas
  	for ij=1:numSigmas
      %if ij >= ii, continue; end

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
      end
      sigma_pairs(counter, :) = [sigmas(ii), sigmas(ij)];
      counter = counter + 1;
    end
  end 
  
  
  %% Plot data
    
  % Generate legend labels
  C{numSigmas, 1} = {};
  for si=1:numSigmas
     C{si} = sprintf('\\sigma = %d', sigmas(si)); 
  end
  
  % Massage data for plotting
  cc = reshape(crossover_cpi, [numSigmas numSigmas]);
  sp = repmat(sigmas, [numSigmas 1]);
  cc(tril(ones(size(cc))) ~= 0) = nan;  % blank out starting lines
  
  % Do the actual plotting
  figure('Position', [ 116          -5        1079         688]);
  plot(sp', cc', 'o-', 'MarkerSize', 5, 'LineWidth', 5) %change to scatter if desired
  title(sprintf('Crossover for %d x %d image, %d connections, cpi(0)=%.2f.', ...
                p(1).sz, p(1).nConns, p(1).cpi(1)), ...
        'FontSize', 20); 
  legend(C, 'Location', 'SouthWest', 'FontSize', 14);
  xlabel('Sigma 2', 'FontSize', 16);
  ylabel('Crossover frequency (CPI)', 'FontSize', 16);

function [avg_mean, std_mean, std_std, wts_mean, p] = nn_2layer_processor(varargin)
  
  [raw_avg, raw_std, ~, raw_wts, p] = nn_2layer(varargin{:});

  avg_mean = mean(raw_avg,1);  % mean of means
  std_mean = mean(raw_std,1);  % mean of standard deviations
  std_std  = std(raw_std,[],1)/sqrt(size(raw_std,1));
  wts_mean = squeeze(mean(raw_wts,1));
