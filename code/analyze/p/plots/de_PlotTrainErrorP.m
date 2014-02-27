function [fig] = de_PlotTrainErrorP(mSets, stats)
%function [fig] = de_PlotTrainErrorP(mSets, stats)
%

  % Plot 1: just compare the means
  fig = de_NewFig('train-error', 'bars', 2, length(mSets.sigma));

  % 4 -cell plot: ac&p, raw&rej
  plotNum = 1;
  for o1={'raw' 'rej'}
      data = stats.(o1{1}).p.err.vals;
      pval = stats.(o1{1}).p.err.pval;

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
      hold on;
      title(sprintf('P %s (p<=%4.2f)', o1{1}, pval));

      plotNum = plotNum + 1;
  end;

  % Plot 2: show distributions of errors for each sigma
%  for
%  [nRows,nCols] = guru_optSubplots(length(stats.