function [fig] = de_PlotTrainItersAC(mSets, stats)
%function [fig] = de_PlotTrainingIters(mSets, stats)
%
  fig = de_NewFig('train-iters', 'bars', 2, length(mSets.sigma));

  % 4 -cell plot: ac&p, raw&rej
  plotNum = 1;
  for o1={'raw' 'rej'}
      data = stats.(o1{1}).ac.ti.vals;
      pval = stats.(o1{1}).ac.ti.pval;

      % Calculate summary data
      means = zeros(size(data));
      stdes = zeros(size(data));

      for ss=1:length(data)
        d = data{ss};
        means(ss) = mean(d);
        stdes(ss) = guru_stde(d);
      end;

      % Plot results
      subplot(1, 2, plotNum);

      guru_bar(means, stdes, guru_csprintf('o=%3.1f', num2cell(mSets.sigma)));
      set(gca,'FontSize',14);
      title(sprintf('AC %s (p=%4.2f)', o1{1}, pval), 'FontSize', 16);

      plotNum = plotNum + 1;
  end;
