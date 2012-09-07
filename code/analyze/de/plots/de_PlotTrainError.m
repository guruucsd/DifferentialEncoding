function [fig] = de_PlotTotalOutput(mSets, stats)
%function [fig] = de_PlotTotalOutput(mSets, stats)
%

  % Plot 1: just compare the means
  fig = guru_newFig('train-error', 'bars', 4, length(mSets.sigma));
  
  % 4 -cell plot: ac&p, raw&rej
  plotNum = 1;
  for o1={'raw' 'rej'}
    for o2={'AC', 'P'}
      data = stats.(o1{1}).err.(o2{1});

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
      hold on; 
      title(sprintf('%s.%s', o1{1}, o2{1}));
      
      plotNum = plotNum + 1;
    end;
  end;
  
  % Plot 2: show distributions of errors for each sigma
%  for 
%  [nRows,nCols] = guru_optSubplots(length(stats.