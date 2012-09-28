function figs = de_FigurizerLSB(mSets, mss, stats)
  figs = de_NewFig('dummy');

  if (ismember(1, mSets.debug)), fprintf('Doing selected LSB plots...\n'); end;

  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------

  for ss=1:length(mSets.sigma)
    ms = mss(:,ss);
  end;  %ss

