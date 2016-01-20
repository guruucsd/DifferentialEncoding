% See Slotnick, et al. 2001: Figure 2 for comparison.

function [ss] = okubo_interaction_analysis(all_stats)

  ss.cate = all_stats{1};
  ss.coor = all_stats{2};
  ss.cb_cate = all_stats{3};
  ss.cb_coor = all_stats{4};
  ss.group = de_StatsGroupAnovaOkubo( ss );
  %[figs] = de_PlotGroupBasicsSlot(ms, ss);
  %de_SavePlots(mSets, figs);
end