function out = de_SaveStats(mSets, stats)
%
%

  % Save stats to output .mat file
  out = mSets.out;
  fn  =  de_GetOutFile(mSets, 'stats');
  
  fprintf('Saving stats to %s\n', fn);

  save( fn, 'stats', '-v7.3' );
  
