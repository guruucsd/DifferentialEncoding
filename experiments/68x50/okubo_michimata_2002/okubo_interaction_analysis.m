% See Slotnick, et al. 2001: Figure 2 for comparison.

function [ms,ss] = okubo_interaction_analysis(all_stats)

  ss = all_stats;
  ss.group = de_StatsGroupAnovaOkubo( ss );
  %[figs] = de_PlotGroupBasicsSlot(ms, ss);
  %de_SavePlots(mSets, figs);
end