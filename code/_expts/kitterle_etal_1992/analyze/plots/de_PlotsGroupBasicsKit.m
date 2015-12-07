function figs = de_PlotsGroupBasicsKit( mSets, ms, ss )

  figs = de_NewFig('dummy');

  dss = {'train','test'};
  for dsi=1:length(dss)
    for measure={'linear', 'log'}
      ds = dss{dsi};

      % Get mean and std for each hemi in each task
      % ss.(task).rej.sf.rej.basics.perf.(ds) = { nmodels, nfreq, sin/sq }
      % K>> mean(mean(ss.freq.rej.sf.rej.basics.perf.train{1},3),2)

      means = [ cellfun(@(p) mean(p(:)), ss.freq.rej.sf.rej.basics.perf.(ds)); ...
                cellfun(@(p) mean(p(:)), ss.type.rej.sf.rej.basics.perf.(ds))  ]

      if strcmp(measure{1}, 'log')
        perf = log10(means);
        ylbl = 'log_{10}(Mean Square Error)';
      else
        perf = means;
        ylbl = 'Mean Square Error';
      end;

      figs(end+1) = de_NewFig(sprintf('%s-%s', ds, measure{1}));
      hold on;

      task_lbls = {'Wide/Narrow','Sharp/Fuzzy'};
      if size(means, 1) == 2
          hemi_lbls = { sprintf('RH (\\sigma=%3.1f)', mSets.sigma(1)), ...
                        sprintf('LH (\\sigma=%3.1f)', mSets.sigma(end))};
          plot(1, perf(2,1), 'ko', 'MarkerSize', 15.0, 'MarkerFaceColor','k');
          plot(1, perf(1,1), 'ko', 'MarkerSize', 15.0);
          plot(2, perf(2,2), 'ko', 'MarkerSize', 15.0, 'MarkerFaceColor','k');
          plot(2, perf(1,2), 'ko', 'MarkerSize', 15.0);
          plot([1 2], perf(1,:), 'k', 'LineWidth', 2.0);
          plot([1 2], perf(2,:), 'k', 'LineWidth', 2.0);
          text(2.125, perf(1,2), hemi_lbls{1}, 'FontSize', 18)
          text(2.125, perf(2,2), hemi_lbls{2}, 'FontSize', 18)
      else
          plot(repmat([1 2],[size(perf,1) 1])', perf, 'o-', ...
               'MarkerSize', 10, 'LineWidth', 2.0);
          sigmas = arrayfun(@(m) sprintf('%6.2f', m.sigma), ms.freq(1,:), ...
                            'UniformOutput', false);
          legend(sigmas, 'Location', 'NorthEast');
      end;

      xlim([0.45 2.75+.8]);
      set(gca, 'FontSize', 18.0, 'xtick', [1 2], 'xticklabel', task_lbls);
      ylabel(ylbl);
    end;
  end;
