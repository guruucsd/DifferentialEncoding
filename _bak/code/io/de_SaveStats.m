function out = de_SaveStats(mSets, stats)
%
%

  % Save stats to output .mat file
  out = mSets.out;
  
  save( de_GetOutFile(mSets, 'stats'), 'stats' );
  