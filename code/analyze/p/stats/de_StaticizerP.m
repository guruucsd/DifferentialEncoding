function [stats] = de_StaticizerP(mSets, mss, stats, stc)  
%
  if (~exist('stc','var')), stc = mSets.stats; end;
  if (~exist('stats','var')), stats = []; end;
  
  % Default set of stats
  if (guru_contains('default', stc))
    default_stats = {'err', 'tt', 'ti'};
    stc = setdiff(unique({stc{:} default_stats{:}}), {'default'});
  end;
  
  
  % Basic, non-optional stats
  if (~isfield(mSets.data, 'err')), [stats] = de_DoStat([], stats, 'err', stc, 'de_StatsTrainErrorP', mss); end;
  if (~isfield(mSets.data, 'tt')),  [stats] = de_DoStat([], stats, 'tt',  stc, 'de_StatsTrainTimeP',  mss); end;
  if (~isfield(mSets.data, 'ti')),  [stats] = de_DoStat([], stats, 'ti',  stc, 'de_StatsTrainItersP', mss); end;
  
  if (~isfield(mSets.data, 'weights')),  [stats] = de_DoStat('weights', stats, 'weights',  stc, 'de_StatsWeights', mss); end;
