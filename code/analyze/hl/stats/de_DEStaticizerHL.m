function [stats] = de_DEStaticizerHL(mSets, mss, stats)  
%

  % Get the basic stats for before-rejections
  [stats.raw]    = de_DoStat([], stats.raw, 'basics', mSets.stats, 'de_StatsBasicsHL', mSets, mss);
  
  % Reject any models that don't fit the specified criteria
  %   Also converts models to a cell array.
  [stats.raw.r, mss] = de_DoRejectionsHL(mss, mSets.rej.types, mSets.rej.width);

  % Get the basic stats for after-rejections
  [stats.rej]    = de_DoStat([], stats.rej, 'basics', mSets.stats, 'de_StatsBasicsHL', mSets, mss, ismember(1,mSets.debug));
  

  % optional stats
  [stats.rej] = de_DoStat('vs',  stats.rej, 'hum', mSets.stats, 'de_StatsVsHuman', mSets, stats.rej.basics.ls);

  if (~isfield(stats.rej,'opt')),   [stats.rej.opt] = []; end;
  if (isfield(mSets.data, 'test')), [stats.rej.opt] = de_DoStat('opt', stats.rej.opt, 'test',  mSets.stats, 'de_StatsOptimal', stats.rej.huacts.test,  mSets.data.test);
  else,                             [stats.rej.opt] = de_DoStat('opt', stats.rej.opt, 'train', mSets.stats, 'de_StatsOptimal', stats.rej.huacts.train, mSets.data.train); end;
  
  