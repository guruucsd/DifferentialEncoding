function [fig] = de_PlotNumRejections(mSets, stats)
%function [fig] = de_PlotTotalOutput(mSets, stats)
%

  fig.name   = 'num_rejects';
  fig.handle = figure;

  data = zeros(size(stats.raw.r));
  for i=1:length(stats.raw.r)
    data(i) = length(find(sum(stats.raw.r{i},2)));
  end;

  mfe_barweb(data, zeros(size(data)), 0.9, guru_csprintf('%5.1f', num2cell(mSets.sigma)));
  hold on;
  title(sprintf('# Rejections'));
