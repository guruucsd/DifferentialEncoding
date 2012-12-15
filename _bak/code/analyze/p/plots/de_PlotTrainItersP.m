function [fig] = de_PlotTrainingIters(mSets, stats)
%function [fig] = de_PlotTrainingIters(mSets, stats)
%
  fig = de_NewFig('train-iters', 'bars', 2, length(mSets.sigma));
  
  % 4 -cell plot: ac&p, raw&rej
  plotNum = 1;
  for o1={'raw' 'rej'}
      data = stats.(o1{1}).p.ti;

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
      title(sprintf('P %s', o1{1}));
      
      plotNum = plotNum + 1;
  end;
