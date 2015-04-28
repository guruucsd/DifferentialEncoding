function centersurround()

  freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5];
  args  = { 'w_mode', 'center-surround', ...
            'freqs',  freqs, ...
            'nin',    25, ...
            'nsamps', 1, ...
            'nbatches', 1 ...
         };

  std_mean = zeros(0, length(freqs));
  avg_mean = zeros(size(std_mean));
  f        = zeros(0,1);
  wts_mean = zeros(0, 20, 20);

  % Circular

  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'Sigma', [20 0; 0 20]/2);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'Sigma', [20 0; 0 20]/8);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'Sigma', [20 0; 0 20]/16);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'Sigma', [20 0; 0 20]/32);
  ncirc = size(std_mean,1);

  % Plot Circular
  figure;
  ns_mean = std_mean(1:ncirc,:)./repmat(max(std_mean,[],2), [1 length(freqs)]);

  plot(freqs, std_mean(1:ncirc,:)');
  legend(guru_csprintf('c%d', num2cell(1:ncirc)));

  keyboard


function [avg_mean, std_mean, wts_mean, f] = nn_2layer_processor(varargin)

  [std_avg, std_std, ~, wts] = nn_2layer(varargin{:});

  avg_mean = mean(std_avg,1);
  std_mean = mean(std_std,1);
  wts_mean = squeeze(mean(wts,1));
  f = figure; imagesc(wts_mean); colorbar;
  
