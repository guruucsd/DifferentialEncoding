function figs = de_PlotFreqPreferences(mSets, stats)
% Find the max index at each location.

    sigmas = mSets.sigma;
    n_sigmas = length(sigmas);
    dset = stats.settings.dset;
    figs = de_VisualizeDataset(dset);

    for prop={'freq', 'orient', 'phase'}
      prop = prop{1};
      prop_vals = dset.([guru_iff(strcmp(prop, 'freq'), 'cycle', prop) 's']);
      n_prop_vals = length(prop_vals);

      for val={'mean', 'std'}
        val=val{1};

        norm_imgs = nan(n_sigmas, mSets.nInput(1), mSets.nInput(2));
        distn = nan(n_sigmas, n_prop_vals);

        for si=1:n_sigmas
          [~, max_resp_idx] = max(stats.(prop).(val){si}, [], 3);
          n_models = size(max_resp_idx, 1);
          imgs = reshape(max_resp_idx, [n_models * mSets.hpl(si), mSets.nInput]);

          % distribution of the average max, across the image.
          norm_imgs(si, :, :) = mean(imgs, 1);

          % distribution of preferences
          distn(si, :) = histc(imgs(:), 1:n_prop_vals) / numel(imgs);
        end;

        % Figure 1
        if false
          figs(end+1) = de_NewFig(sprintf('%s-%s-pref-as-image', val, prop));

          for si=1:n_sigmas
            subplot(1, n_sigmas + 1, si);
            imagesc(squeeze(norm_imgs(si, :, :)), [1 n_prop_vals]);
          end;

          distn_diff = diff(norm_imgs([1 end], :, :), 1, 1);
          subplot(1, n_sigmas + 1, n_sigmas + 1);
          imagesc(squeeze(distn_diff), (n_prop_vals - 1) * [-1 1]);
          xlabel(sprintf('RH - LH %s %s preference', val, prop));

          colormap jet;
          set(figs(end).handle, 'Position', [0, 0, 1200, 600]);
        end;

        % Figure 2
        figs(end+1) = de_NewFig(sprintf('%s-%s-pref-distns', val, prop));
        bar(distn');
        legend(arrayfun(@(s) sprintf('%.2f', s), sigmas, 'UniformOutput', false));
        xticks = get(gca, 'xtick');
        hit_idx = 1 <= xticks & xticks <= n_prop_vals;
        xticklabels = arrayfun( ...
          @(v) sprintf('%.2f', v), prop_vals(xticks(hit_idx)), ...
          'UniformOutput', false ...
        );
        set(gca, 'xtick', xticks(hit_idx), 'xticklabel', xticklabels);
        xlabel(prop);
        ylabel('Proportion of units');
        title(sprintf('%s %s', val, prop));
        set(figs(end).handle, 'Position', [0, 0, 1200, 800]);
      end;  % val
    end;  % prop
    
    % Now for the Recfields code. Stick to naming convention in recfields,
    % which requires taking information from structs.
    
    crossover_cpi = stats.freq.xover;
    sigma_pairs = stats.freq.spairs;
    sigmas = mSets.sigma;
    numSigmas = length(sigmas);
    std_mean = stats.freq.std_mean;
    std_ste = stats.freq.std_ste;
    freqs = stats.freq.cpi;
    cpi = freqs;
    
    %% Plot data

    % Generate legend labels
    C{numSigmas, 1} = {};
    for si=1:numSigmas
      C{si} = sprintf('\\sigma = %d', sigmas(si));
    end

    % Massage data for plotting
    cc = crossover_cpi';
    sp = repmat(sigmas, [numSigmas 1]);

    % Do the actual plotting
    figs(end+1) = de_NewFig('sigma vs. crossover');

    set(figs(end).handle,'Position', [ 0 0 1024 768]);
    plot(sp', cc', 'o-', 'MarkerSize', 5, 'LineWidth', 5) %change to scatter if desired
    title(sprintf('Crossover for %d x %d image, %d connections, cpi(0)=%.2f.', ...
                mSets.nInput, mSets.nConns(1), stats.freq.cpi(1)), ...
          'FontSize', 20);
    legend(C, 'Location', 'SouthWest', 'FontSize', 14);
    xlabel('Sigma 2', 'FontSize', 16);
    ylabel('Crossover frequency (CPI)', 'FontSize', 16);

    scaling = max(abs(std_mean(:))); % Rescale over all sigmas, such that the scale of response isn't a factor
    max_std = repmat(max(abs(std_mean),[],2), [1 length(freqs)]); % can normalize each sigma's response so that it's peak is 1
    %max_std = avg_mean;
    ns_mean = std_mean./max_std;
    ns_std  = std_ste./sqrt(max_std);

    lbls = cell(size(sigmas));
    for si=1:length(sigmas)
        lbls{si} = sprintf('sigma = %.2f', sigmas(si));
    end;

    % Plots the mean (across all units) of the standard deviation of each
    % units' response to different frequency gratings (frequency, phase,
    % orientation)

    colors = @(si) (reshape(repmat(numel(sigmas)-si(:), [1 3])/numel(sigmas) * 1 .* repmat([1 0 0],[numel(si) 1]),[numel(si) 3]));

    figs(end+1) = de_NewFig('output std vs. frequency per sigma');
    set(figs(end).handle,'position', [0, 0, 768, 768]);
    hold on;
    %plot(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean/scaling)', 'LineWidth', 2);
    %errorbar(repmat(cpi,[size(avg_mean,1) 1])', (sign(avg_mean).*std_mean)'/scaling, std_ste'/scaling);
    for si=1:length(sigmas)
      plot(cpi, std_mean(si,:)/scaling, '*-', 'Color', colors(si), 'LineWidth', 3, 'MarkerSize', 5);
    end;
    for si=1:length(sigmas)
      errorbar(cpi, std_mean(si,:)/scaling, std_ste(si,:)/scaling, 'Color', colors(si));
    end;
    set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
    set(gca, 'FontSize', 16);
    xlabel('frequency (cycles per image)');
    ylabel('output activity (linear xfer fn)');
    legend(lbls, 'Location', 'best', 'FontSize',16);
    title('Non-normalized std (divided by global mean)');

end

    
