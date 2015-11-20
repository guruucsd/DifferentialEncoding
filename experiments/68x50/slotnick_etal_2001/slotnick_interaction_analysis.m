% See Slotnick, et al. 2001: Figure 2 for comparison.

function [ms,ss] = slotnick_interaction_analysis(tst_cate, tst_coor)

  % Reconstitute into expected format
  ms.cate = tst_cate.models;
  ms.coor = tst_coor.models;
  ss.cate = tst_cate.stats;
  ss.coor = tst_coor.stats;
  mSets   = tst_cate.mSets;

  ss.group = de_StatsGroupBasicsSlot( mSets, ms, ss );
  de_PlotGroupBasicsSlot(ms, ss);
end