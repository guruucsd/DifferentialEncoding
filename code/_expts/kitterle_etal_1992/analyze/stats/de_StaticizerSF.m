 function [stats] = de_StaticizerSF(mSets, mss, stats)  
%

  % Get the basic stats for before-rejections
  [stats.raw]    = []; %de_DoStat([], stats.raw, 'basics', mSets.stats, 'de_StatsBasicsSF', mSets, mss);
  
  % Reject any models that don't fit the specified criteria
  %   Also converts models to a cell array.
%  [stats.raw.r, mss] = de_DoRejectionsHL(mss, mSets.rej.type, mSets.rej.width);

  % Get the basic stats for after-rejections
  [stats.rej]    = de_DoStat([], stats.rej, 'basics', mSets.stats, 'de_StatsBasicsSF', mSets, mss, ismember(1,mSets.debug));
  

  % optional stats
  