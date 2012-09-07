function [fig] = de_PlotTrainingIters(mSets, stats)
%function [fig] = de_PlotTrainingIters(mSets, stats)
%
  fig = guru_newFig('train-iters', 'bars', 4, length(mSets.sigma));
  
  % 4 -cell plot: ac&p, raw&rej
  plotNum = 1;
  for o1={'raw' 'rej'}
    for o2={'AC', 'P'}
      data = stats.(o1{1}).ti.(o2{1});

      % Calculate summary data
      means = zeros(size(data));
      stdes = zeros(size(data));
      
      for ss=1:length(data)
        d = data{ss} / (prod(mSets.nInput)*size(mSets.data.train.T,2));
        means(ss) = mean(d);
        stdes(ss) = guru_stde(d);
      end;

      % Plot results
      subplot(2, 2, plotNum);
      
      guru_bar(means, stdes, guru_csprintf('o=%3.1f', num2cell(mSets.sigma)));
      title(sprintf('%s.%s', o1{1}, o2{1}));
      
      plotNum = plotNum + 1;
    end;
  end;
