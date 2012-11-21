function [stats] = de_StaticizerAC(mSets, mss, stats, stc)
%

  if (~exist('stc','var')),  stc = mSets.stats; end;
  if (~exist('stats','var')), stats = []; end;

  % Default set of stats
  if (guru_contains('default', stc))
    default_stats = {'err', 'tt', 'ti'};
    stc = setdiff(unique([stc default_stats]), {'default'});
  end;


  % Basic stats
  if (~isfield(mSets.data, 'err')), [stats] = de_DoStat('err', stats, 'err', stc, 'de_StatsTrainErrorAC', mss); end;
  if (~isfield(mSets.data, 'tt')),  [stats] = de_DoStat('tt',  stats, 'tt',  stc, 'de_StatsTrainTimeAC',  mss); end;
  if (~isfield(mSets.data, 'ti')),  [stats] = de_DoStat('ti',  stats, 'ti',  stc, 'de_StatsTrainItersAC', mss); end;
  if (~isfield(mSets.data, 'ipd')), [stats] = de_DoStat('ipd', stats, 'ipd', stc, 'de_StatsInterpatchDistance', mss); end;
  if (~isfield(mSets.data, 'sta')), [stats] = de_DoStat('sta', stats, 'sta', stc, 'de_StatsSTA', mss); end;

  % Optional stats

  % Images is needed by ffts
  if (~ismember('images',stc) && ismember('ffts',stc)), stc{end+1} = 'images'; end;

  if (~isfield(stats, 'images')), stats.images = []; end;
  if (isfield(mSets.data, 'test')), [stats.images] = de_DoStat('images', stats.images, 'test',  stc, 'de_StatsOutputImages', mss, mSets.data.test);
  else,                             [stats.images] = de_DoStat('images', stats.images, 'train', stc, 'de_StatsOutputImages', mss, mSets.data.train); end;

  if (~isfield(stats, 'ffts')), stats.ffts = []; end;
  if (isfield(mSets.data, 'test')),
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'orig',  stc, 'de_StatsFFTs',       mSets.data.test.X(1:end-1,:),  mSets.data.test.nInput);
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'model', stc, 'de_StatsFFTs',       stats.images.test,             mSets.data.test.nInput);
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'pals', stc, 'de_StatsFFTs_TTest',  stats.ffts);
  else,
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'orig',  stc, 'de_StatsFFTs',       mSets.data.train.X(1:end-1,:), mSets.data.train.nInput);
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'model', stc, 'de_StatsFFTs',       stats.images.train,            mSets.data.test.nInput);
      [stats.ffts] = de_DoStat('ffts', stats.ffts, 'pals', stc, 'de_StatsFFTs_TTest',  stats.ffts);
  end;

  [stats] = de_DoStat('distns', stats, 'distns',  stc, 'de_StatsDistributions', mss);
  [stats] = de_DoStat('freqprefs', stats, 'freqprefs',  stc, 'de_StatsFreqPreferences', mss);


  if (~isfield(stats, 'images')), stats.images = []; end;
  if (isfield(mSets.data, 'test')), [stats.images] = de_DoStat('images', stats.images, 'test',  stc, 'de_StatsOutputImages', mss, mSets.data.test);
  else,                             [stats.images] = de_DoStat('images', stats.images, 'train', stc, 'de_StatsOutputImages', mss, mSets.data.train); end;

  if (~isfield(stats, 'huencs')), stats.huencs = []; end;
  if (isfield(mSets.data, 'test')), [stats.huencs] = de_DoStat('hu-encodings', stats.huencs, 'test',  stc, 'de_StatsHUEncodings', mss, mSets.data.test);
  else,                             [stats.huencs] = de_DoStat('hu-encodings', stats.huencs, 'train', stc, 'de_StatsHUEncodings', mss, mSets.data.train); end;

  if (~isfield(stats, 'huouts')), stats.huouts = []; end;
  if (isfield(mSets.data, 'test')), [stats.huouts] = de_DoStat('hu-output', stats.huouts, 'test',  stc, 'de_StatsHUOutputs', mss, mSets.data.test);
  else,                             [stats.huouts] = de_DoStat('hu-output', stats.huouts, 'train', stc, 'de_StatsHUOutputs', mss, mSets.data.train); end;
