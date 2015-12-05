function figs = de_PlotFreqPreferences(mSets, stats)
% Find the max index at each location.

    freqs = stats.settings.cpi;
    n_freqs = length(freqs);
    sigmas = mSets.sigma;
    n_sigmas = length(sigmas);

    norm_imgs = zeros(n_sigmas, mSets.nInput(1), mSets.nInput(2));
    distn = zeros(n_sigmas, n_freqs);

    figs = de_NewFig('dummy');

    for si=1:n_sigmas
      [~, max_resp_idx] = max(stats.avg_resp{si}, [], 3);

      n_models = size(max_resp_idx, 1);    
      imgs = reshape(max_resp_idx, [n_models * mSets.hpl(si), mSets.nInput]);

      % Plot 1: distribution of the average max, across the image.
      norm_imgs(si, :, :) = mean(imgs);

      % Plot 2
      distn(si, :) = histc(imgs(:), 1:n_freqs) / numel(imgs);
    end;

    if true
      figs = de_NewFig('freq-pref-as-image');
      set(figs(end).handle, 'Position', [0, 0, 1200, 600]);

      for si=1:n_sigmas
        subplot(1, n_sigmas + 1, si);
        imshow(squeeze(norm_imgs(si, :, :)), [1 n_freqs]);
        colorbar;
      end;

      subplot(1, n_sigmas + 1, n_sigmas + 1);
      distn_diff = diff(norm_imgs([1 end], :, :), 1, 1);
      imshow(squeeze(distn_diff), (n_freqs - 1) * [-1 1]);
      colorbar;
      xlabel('RH preference - LH preference');

      colormap jet;
    end;


    if true
      figs(end+1) = de_NewFig('freq-pref-distns');
      bar(distn');
      set(gca, 'xticklabel', freqs(get(gca, 'xtick')));
      xlabel('Frequency (cpi)');
      ylabel('Proportion of units');
    end;
