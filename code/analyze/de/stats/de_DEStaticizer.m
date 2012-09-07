function [stats] = de_DEStaticizer(mSets, mss, stc)  
%
  if (~exist('stc','var')), stc = mSets.stats; end;

  % Default set of stats
  if (guru_contains('default', stc))
    default_stats = {};
    stc = setdiff(unique({stc{:} default_stats{:}}), {'default'});
  end;
  
  
  % Basic, non-optional stats
  stats = [];
  [stats] = de_DoStat([], stats, 'err', stc, 'de_StatsTrainError', mss);
  [stats] = de_DoStat([], stats, 'tt',  stc, 'de_StatsTrainTime',  mss);
  [stats] = de_DoStat([], stats, 'ti',  stc, 'de_StatsTrainIters', mss);

  % Optional stats
  if (~isfield(stats, 'ffts')), stats.ffts = []; end;
  if (isfield(mSets.data, 'test')), [stats.ffts] = de_DoStat('ffts', stats.ffts, 'test',  stc, 'de_StatsFFTs', mss, mSets.data.test);
  else,                             [stats.ffts] = de_DoStat('ffts', stats.ffts, 'train', stc, 'de_StatsFFTs', mss, mSets.data.train); end;

  if (~isfield(stats, 'huacts')), stats.huacts = []; end;
  if (isfield(mSets.data, 'test')), [stats.huacts] = de_DoStat('huacts', stats.huacts, 'test',  stc, 'de_StatsHUActivations', mss, mSets.data.test);
  else,                             [stats.huacts] = de_DoStat('huacts', stats.huacts, 'train', stc, 'de_StatsHUActivations', mss, mSets.data.train); end;

  [stats] = de_DoStat('weights', stats, 'weights',  stc, 'de_StatsWeights', mss);
