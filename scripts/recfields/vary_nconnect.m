function vary_nconnect()

%  freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5]; % using only harmonics
  freqs = [ 0.0001 0.01 * [ 2 4 6 8 10 12 14 16 18 20 25 30 35 50]]; %using non-harmonics
  nin = [2 5 10 20 200];%200, 20, 10, 5, 2];
  cpi   = freqs/0.06;
  args  = { 'seed', 1, ...
            'w_mode', 'posmean', ...
            'a_mode', 'mean', ...
            'freqs',  freqs, ...
            'Sigma', [20 0; 0 20]/2, ...
            'distn', 'norme2', ...
            'nsamps', 10, ...
            'nbatches', 10 ...
         };

  % run the thing and collect stats!
  avg_mean = zeros(0, length(freqs));
  std_mean = zeros(0, length(freqs));
  std_std  = zeros(0, length(freqs));
  f        = zeros(0,1);
  wts_mean = zeros(0, 20, 20);

  % Circular
  if (exist('vary_nconnect.mat'))
      load('vary_nconnect.mat');
  else
      for ni=1:length(nin)
          [avg_mean(end+1,:),std_mean(end+1,:),std_std(end+1,:),wts_mean(end+1,:,:),pt,f(end+1)]=nn_2layer_processor(args{:}, 'nin', nin(ni));
          if (ni==1), p=pt;
          else, p(end+1)=pt; end;
      end;
  end;
  
  %lbls = guru_csprintf( sprintf('%%3d cxns \\\\sigma=%3.1fpix', p(1).Sigma(1)), num2cell(nin));
  lbls = guru_csprintf( '%3d cxns', num2cell(nin));

  %
  scaling = max(std_mean(:));
  max_std = repmat(max(abs(std_mean),[],2), [1 length(freqs)]);
  %max_std = avg_mean;
  ns_mean = std_mean./max_std;
  ns_std  = std_std./sqrt(max_std);
  
  % sanity check; check the average 
  figure; plot(cpi, avg_mean', '.-');
  legend(lbls);
  xlabel('frequency (cycles per image)');

  % non-normalized
  figure; 
  hold on;
  plot(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean/scaling)', 'LineWidth', 2);
  errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean)'/scaling, std_std'/sqrt(scaling));
  set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
  set(gca, 'FontSize', 16);
  xlabel('frequency (cycles per image)');
  ylabel('output activity (linear xfer fn)');
  legend(lbls, 'Location', 'best', 'FontSize',16);
  
  % normalized
  figure; 
  hold on;
  plot(cpi, (sign(avg_mean).*ns_mean)', 'LineWidth', 2);
  errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*ns_mean)', 10* ns_std');
  set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
  set(gca, 'FontSize', 16);
  xlabel('frequency (cycles per image)');
  ylabel('output activity (normalized)');
  legend(lbls, 'Location', 'best', 'FontSize',14);
  
  %figure;
  %subplot(1,3,1); imshow(0.5+mfe_grating2d( 0.06, 0, pi/2, 0.5, 20, 20 ));
  %subplot(1,3,2); imagesc(squeeze(wts_mean(2,:,:)));
  %subplot(1,3,3); imshow(0.5+mfe_grating2d( 0.08, 0, pi/2, 0.5, 20, 20 ));

  save('vary_nconnect.mat');
  

function [avg_mean, std_mean, std_std, wts_mean, p, f] = nn_2layer_processor(varargin)

  [raw_std_avg, raw_std_std, ~, raw_wts, p] = nn_2layer(varargin{:});

  avg_mean = mean(raw_std_avg,1);
  std_mean = mean(raw_std_std,1);
  std_std  = std(raw_std_std,[],1)/sqrt(size(raw_std_std,1));
  wts_mean = squeeze(mean(raw_wts,1));
  f = figure; imagesc(wts_mean); colorbar;
  
