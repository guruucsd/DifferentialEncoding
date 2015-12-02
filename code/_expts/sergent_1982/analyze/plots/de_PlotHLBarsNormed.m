function [fig] = de_PlotHLBarsNormd(mSets, stats)
%function [h] = de_PlotHLBarsNormd(modelSettings)


  tidx = [mSets.data.aux.idx.LpSpID mSets.data.aux.idx.LpSpNID ...
          mSets.data.aux.idx.LpSm   mSets.data.aux.idx.LmSp  ...
          mSets.data.aux.idx.LmSmID mSets.data.aux.idx.LmSmNID];

  new_stats = stats;
  new_stats.basics.bars(tidx, :);
  new_stats.basics.bars_stde(tidx, :);

  scale_factors = mean(new_stats.basics.bars(tidx, :), 1);
  rep_scale_factors = repmat(scale_factors, [length(tidx) 1]);
  new_stats.basics.bars(tidx, :) = new_stats.basics.bars(tidx, :) ./ rep_scale_factors;
  new_stats.basics.bars_stde(tidx, :) = new_stats.basics.bars_stde(tidx, :) ./ rep_scale_factors;

  fig = de_PlotHLBars(mSets, new_stats);
  fig.name = 'ls-bars-normd';
