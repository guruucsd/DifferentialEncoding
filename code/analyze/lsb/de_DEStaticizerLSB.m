function [stats] = de_DEStaticizerLSB(mSets, mss, stats)  
%

  if (ismember(1, mSets.debug)), fprintf('Doing selected LSB stats...\n'); end;
  