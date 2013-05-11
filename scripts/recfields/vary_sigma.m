 function [avg_mean, std_mean, std_std, wts_mean, p] = vary_sigma(varargin)
%
%
%

  if ~exist('guru_popopt','file'), addpath(genpath('../../code')); end;

%  freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5]; % using only harmonics
  %freqs = [ 0.0001 0.01 * [ 2 4 6 8 10 12 14 16 18 20 25 30 35 50]]; %using non-harmonics
  
  [sigmas, varargin] = guru_popopt(varargin, 'Sigmas', 20*[1/32 1/16 1/8 1/2 2 8]);%8 2 1/2 1/8 1/16 1/32];
  [cpi,    varargin] = guru_popopt(varargin, 'cpi',    [0.25 0.5 1 1.5 2 3 4]);%8 2 1/2 1/8 1/16 1/32];
 
  args  = { 'seed', 1, ...
            'w_mode', 'posmean', ...
            'a_mode', 'mean', ...
            'cpi',  cpi, ...
            'nin', 10, ...
            'distn', 'norme', ...
            'nsamps', 25, ...
            'nbatches', 1 ...
            'img2pol', false, ...
            'disp', [10 11 12 13], ...
            varargin{:} ...
         };
  

  %% Reload file
  outfile = sprintf('%s.mat', mfilename());
  if (false && exist(outfile,'file'))
      load(outfile);
      return;
  end;
  
  
  %% Run from scratch
  for ni=1:length(sigmas)

      [am,sm,ss,wm,pt,ft]=nn_2layer_processor(args{:}, 'Sigma', sigmas(ni)*[1 0;0 1]); % circular gaussian

      if (ni==1)
          freqs = pt.freqs;

          % run the thing and collect stats!
          avg_mean = zeros(length(sigmas), length(freqs));
          std_mean = zeros(length(sigmas), length(freqs));
          std_std  = zeros(length(sigmas), length(freqs));
          f        = zeros(length(sigmas),1);
          wts_mean = zeros(length(sigmas), size(wm,1), size(wm,2));

          p=pt(1:0);
      end;

      avg_mean(ni, :) = am;
      std_mean(ni,:) = sm;
      std_std(ni, :) = ss;
      f(ni) = ft;
      wts_mean(ni,:,:) = wm;
      p(end+1)=pt; 
  end;

  
  %% Plots
%  avg_dist = [p.avg_dist];
%  lbls = guru_csprintf( '\\sigma=%3.1fpx', num2cell(sigmas));
%  lbls = guru_csprintf( '\\avg__dist=%.1fpx', num2cell(avg_dist));
  lbls = cell(size(p));
  for pi=1:length(p)
      lbls{pi} = sprintf('d_{center}=%.1f%% (%.1fpx); d_{nn} = %.1f%% (%.1fpx)', ...
                         100*p(pi).avg_dist/p(1).sz(1),      p(pi).avg_dist, ...
                         100*mean(p(pi).nn_dist/p(1).sz(1)), mean(p(pi).nn_dist));
  end;
  
  %
  scaling = max(std_mean(:)); % Rescale over all sigmas, such that the scale of response isn't a factor
  max_std = repmat(max(abs(std_mean),[],2), [1 length(freqs)]); % can normalize each sigma's response so that it's peak is 1
  %max_std = avg_mean;
  ns_mean = std_mean./max_std;
  ns_std  = std_std./sqrt(max_std);
  

  % sanity check; check the average 
  if ismember(10, pt.disp)
      figure; plot(cpi, avg_mean', '.-');
      legend(lbls);
      xlabel('frequency (cycles per image)');

      % non-normalized
  end;
  
  if ismember(11, pt.disp)
      colors = @(si) (reshape(repmat(numel(sigmas)-si(:), [1 3])/numel(sigmas) * 1 .* repmat([1 0 0],[numel(si) 1]),[numel(si) 3]));

      figure; 
      hold on;
      %plot(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean/scaling)', 'LineWidth', 2);
      %errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean)'/scaling, std_std'/scaling);
      for si=1:length(sigmas)
        plot(cpi, sign(avg_mean(si,:)).*std_mean(si,:)/scaling, '*-', 'Color', colors(si), 'LineWidth', 3, 'MarkerSize', 5);
      end;
      for si=1:length(sigmas)
        errorbar(cpi, sign(avg_mean(si,:)).*std_mean(si,:)/scaling, std_std(si,:)/scaling, 'Color', colors(si));
      end;
      set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
      set(gca, 'FontSize', 16);
      xlabel('frequency (cycles per image)');
      ylabel('output activity (linear xfer fn)');
      legend(lbls, 'Location', 'best', 'FontSize',16);
      title('Non-normalized std (divided by global mean)');
  
  end;

  % normalized
  if ismember(12, pt.disp)
      figure; 
      hold on;
      plot(cpi, (sign(avg_mean).*ns_mean)', '*-', 'LineWidth', 2);
      errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*ns_mean)', ns_std');
      set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
      set(gca, 'FontSize', 16);
      xlabel('frequency (cycles per image)');
      ylabel('output activity (normalized)');
      legend(lbls, 'Location', 'best', 'FontSize',14);
      title('Normalized std (divided by neuron''s mean)');
      %figure;
      %subplot(1,3,1); imshow(0.5+mfe_grating2d( 0.06, 0, pi/2, 0.5, 20, 20 ));
      %subplot(1,3,2); imagesc(squeeze(wts_mean(2,:,:)));
      %subplot(1,3,3); imshow(0.5+mfe_grating2d( 0.08, 0, pi/2, 0.5, 20, 20 ));
  end;
  
  save(outfile);
  

function [avg_mean, std_mean, std_std, wts_mean, p, f] = nn_2layer_processor(varargin)

  [raw_std_avg, raw_std_std, ~, raw_wts, p] = nn_2layer(varargin{:});

  avg_mean = mean(raw_std_avg,1);
  std_mean = mean(raw_std_std,1);
  std_std  = std(raw_std_std,[],1)/sqrt(size(raw_std_std,1));
  wts_mean = squeeze(mean(raw_wts,1));

  % Calculate average distance
  dist_fn = zeros(size(wts_mean));
  for x=1:size(dist_fn,2), for y=1:size(dist_fn,1), dist_fn(y,x) = sqrt((x-(size(dist_fn,2)+1)/2).^2 + (y-(size(dist_fn,1)+1)/2).^2); end; end;
  p.avg_dist = dist_fn(:)' * (wts_mean(:)/sum(wts_mean(:)));
  
  % Calculate nearest-neighbor distance
  for mi=1:size(raw_wts,1)

    [cy,cx] = find(squeeze(raw_wts(mi,:,:)));
    nn_dist = nan(length(cx));
    for ci=1:length(cx)%  For each connected unit
      for di=(ci+1):length(cx)% Manual search for nearest neighbor
    
        % Interpatch distance
        nn_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
        nn_dist(di,ci) = nn_dist(ci,di); % must include this, for the min below to work.
      end;
    end;
    
    p.nn_dist(mi) = mean(min(nn_dist));
  end;
  
  
  if ismember(13, p.disp)
      f = figure; imagesc(wts_mean); colorbar;
      title(sprintf('\\sigma=%.2fpx; d_{cent}=%.2fpx; d_{nn}=%.2f', p.Sigma(1), p.avg_dist, mean(p.nn_dist)), 'FontSize', 16);
  else
      f = NaN;
  end;
  
  