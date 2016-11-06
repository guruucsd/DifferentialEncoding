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
