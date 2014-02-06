 function vary_sigma_natimg()

%  freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5]; % using only harmonics
  freqs = [ 0.0001 0.01 * [ 2 4 6 8 10 12 14 16 18 20 25 30 35 50]]; %using non-harmonics
  sigmas = 20*[1/32 1/16 1/8 1/2 2 8];%8 2 1/2 1/8 1/16 1/32];
  
  args  = { 'seed', 1, ...
            'w_mode', 'posmean', ...
            'a_mode', 'mean', ...
            'freqs',  freqs, ...
            'nin', 10, ...
            'distn', 'normem2', ...
            'img2pol',true,...
            'nsamps', 10, ...
            'nbatches', 10 ...
         };
  
  cpi   = freqs/0.06;
  % run the thing and collect stats!
  avg_mean = zeros(0, length(freqs));
  std_mean = zeros(0, length(freqs));
  std_std  = zeros(0, length(freqs));
  f        = zeros(0,1);
  wts_mean = zeros(0, 34, 25);

  % Circular
  outfile = sprintf('%s.mat', mfilename());
  if (exist(outfile,'file'))
      load(outfile);
  else
      for ni=1:length(sigmas)
          [avg_mean(end+1,:),std_mean(end+1,:),std_std(end+1,:),wts_mean(end+1,:,:),pt,f(end+1)]=nn_2layer_processor(args{:}, 'Sigma', sigmas(ni)*[1 0;0 1]);
          if (ni==1), p=pt;
          else, p(end+1)=pt; end;
          %closef;
      end;
  end;
  
  lbls = guru_csprintf( '\\sigma=%3.1fpx', num2cell(sigmas));

  %
  scaling = max(std_mean(:)); % make the scaling look close to 1
  max_std = repmat(max(abs(std_mean),[],2), [1 length(freqs)]);
  %max_std = avg_mean;
  ns_mean = std_mean./max_std;
  ns_std  = std_std./sqrt(max_std);
  
  % sanity check; check the average 
  figure; plot(cpi, avg_mean', '.-');
  legend(lbls);
  xlabel('frequency (cycles per image)');
  ylabel('average activity');

  % non-normalized
  colors = @(si) (reshape(repmat(numel(sigmas)-si(:), [1 3])/numel(sigmas) * 1 .* repmat([1 0 0],[numel(si) 1]),[numel(si) 3]));
  figure; 
  hold on;
  %plot(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean/scaling)', 'LineWidth', 2);
  %errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean)'/scaling, std_std'/scaling);
  for si=1:length(sigmas)
    plot(cpi, abs(sign(avg_mean(si,:))).*std_mean(si,:)/scaling, 'Color', colors(si), 'LineWidth', 3);
  end;
  for si=1:length(sigmas)
    errorbar(cpi, abs(sign(avg_mean(si,:))).*std_mean(si,:)/scaling, std_std(si,:)/scaling, 'Color', colors(si));
  end;
  set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
  set(gca, 'FontSize', 16);
  xlabel('frequency (cycles per image)');
  ylabel('output variance (linear xfer fn)');
  legend(lbls, 'Location', 'best', 'FontSize',16);
  
  % normalized
  figure; 
  hold on;
  plot(cpi, abs(sign(avg_mean).*ns_mean)', 'LineWidth', 2);
  errorbar(repmat(cpi,[size(avg_mean,1) 1])', abs(sign(avg_mean).*ns_mean)', ns_std');
  set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
  set(gca, 'FontSize', 16);
  xlabel('frequency (cycles per image)');
  ylabel('output variance (normalized)');
  legend(lbls, 'Location', 'best', 'FontSize',14);
  
  %figure;
  %subplot(1,3,1); imshow(0.5+mfe_grating2d( 0.06, 0, pi/2, 0.5, 20, 20 ));
  %subplot(1,3,2); imagesc(squeeze(wts_mean(2,:,:)));
  %subplot(1,3,3); imshow(0.5+mfe_grating2d( 0.08, 0, pi/2, 0.5, 20, 20 ));

  save(outfile);
  

function [avg_mean, std_mean, std_std, wts_mean, p, f] = nn_2layer_processor(varargin)

  [raw_std_avg, raw_std_std, ~, raw_wts, p] = nn_2layer_natimg(varargin{:});
  avg_mean = mean(raw_std_avg,1);
  std_mean = mean(raw_std_std,1);
  std_std  = std(raw_std_std,[],1)/sqrt(size(raw_std_std,1));
  wts_mean = squeeze(mean(raw_wts,1));
  f = figure; imagesc(wts_mean); colorbar;
  
