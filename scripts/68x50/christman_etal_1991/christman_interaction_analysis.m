function [ms,ss] = christman_interaction_analysis(low_freq, high_freq)

  % Reconstitute into expected format
  ms.low_freq = low_freq.models;
  ms.high_freq = high_freq.models;
  ss.low_freq = low_freq.stats;
  ss.high_freq = low_freq.stats;
  mSets   = low_freq.mSets;

  ss.group = de_StatsGroupBasicsChristman( mSets, ms, ss );

  de_PlotsGroupBasicsChristman( mSets, ms, ss );
