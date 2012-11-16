function fixed()

%  freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5]; % using only harmonics
  freqs = [ 0.0001 0.01 * [ 2 4 6 8 10 12 14 16 18 20 25 30 35 50]]; %using non-harmonics
  args  = { 'w_mode', 'fixed', ...
            'a_mode', 'mean', ...
            'freqs',  freqs, ...
            'Sigma', [20 0; 0 20]/2, ...
            'distn', 'norme', ...
            'nsamps', 3, ...
            'nbatches', 1 ...
         };

  std_mean = zeros(0, length(freqs));
  avg_mean = zeros(size(std_mean));
  f        = zeros(0,1);
  wts_mean = zeros(0, 20, 20);

  % Circular

  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'nin', 200);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'nin', 20);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'nin', 10);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'nin', 5);
  [avg_mean(end+1,:),std_mean(end+1,:),wts_mean(end+1,:,:),f(end+1)]=nn_2layer_processor(args{:}, 'nin', 2);
  ncirc = size(std_mean,1);

  % Plot Circular
  ns_mean = std_mean(1:ncirc,:)./repmat(max(abs(std_mean),[],2), [1 length(freqs)]);

  figure; plot(freqs, (sign(avg_mean).*ns_mean)', '.-');
  legend(guru_csprintf('c%d', num2cell(1:ncirc)));
  figure; plot(freqs, (sign(avg_mean).*std_mean(1:ncirc,:))', '.-');
  legend(guru_csprintf('c%d', num2cell(1:ncirc)));

  %figure;
  %subplot(1,3,1); imshow(0.5+mfe_grating2d( 0.06, 0, pi/2, 0.5, 20, 20 ));
  %subplot(1,3,2); imagesc(squeeze(wts_mean(2,:,:)));
  %subplot(1,3,3); imshow(0.5+mfe_grating2d( 0.08, 0, pi/2, 0.5, 20, 20 ));
  
  figure; plot(freqs, avg_mean', '.-');
  legend(guru_csprintf('c%d', num2cell(1:ncirc)));
  
  
  keyboard

function [avg_mean, std_mean, wts_mean, f] = nn_2layer_processor(varargin)

  [std_avg, std_std, ~, wts] = nn_2layer(varargin{:});

  avg_mean = mean(std_avg,1);
  std_mean = mean(std_std,1);
  wts_mean = squeeze(mean(wts,1));
  f = figure; imagesc(wts_mean); colorbar;
  
