function [ms,ss] = kitterle_interaction_analysis(tst_freq, tst_type)

  % Reconstitute into expected format
  ms.freq = tst_freq.models;
  ms.type = tst_type.models;
  ss.freq = tst_freq.stats;
  ss.type = tst_type.stats;
  mSets   = tst_freq.mSets;

  ss.group = de_StatsGroupBasicsKit( mSets, ms, ss );

  de_PlotsGroupBasicsKit( mSets, ms, ss );
