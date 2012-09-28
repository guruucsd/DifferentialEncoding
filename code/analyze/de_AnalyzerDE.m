function [stats, figs, mss]  = de_Analyzer(mSets, mss, rej)
%function [stats, figs]  = de_Analyzer(mSets, mss)
%

  % Make cell array
  mss = num2cell(mss, 1);

  % Load cached if they exist; only non-present stats will be rerun
  stats = de_LoadStats( mSets, mss );
  figs  = de_LoadFigs( mSets, stats ); % currently always fails to find cached figs
  
  
  % Pull out the most basic stats BEFORE rejections
  [stats.raw.ac]     = de_StaticizerAC(mSets, mss, stats.raw.ac, {'default'});
  if (isfield(mSets,'p'))
      [stats.raw.p]      = de_StaticizerP(mSets, mss, stats.raw.p, {'default'});
  end;
  
  % DO rejections
  %   This "if" statement allows callers to run their own rejection
  %     procedure, instead of what's done here.
  if (exist('rej','var')), stats.raw.r = rej;
  else,                    stats.raw.r = []; end;

  stats.raw.r = de_FindRejectionsAC(mss, mSets.ac.rej, stats.raw, stats.raw.r);
  if (isfield(mSets, 'p'))
      stats.raw.r = de_FindRejectionsP (mss, mSets.p.rej, stats.raw, stats.raw.r);
  end;
  mss_rej     = de_DoRejections( mss, stats.raw.r, ismember(1,mSets.debug));
  

  % Do AC generic stats & figs 
  [stats.rej.ac] = de_StaticizerAC(mSets, mss_rej, stats.rej.ac);
  [figs]         = [figs de_FigurizerAC(mSets, mss_rej, stats)];

  % Do P generic stats & figs
  if (isfield(mSets, 'p'))
    [stats.rej.p]  = de_StaticizerP(mSets, mss_rej, stats.rej.p);
    [figs]         = [figs de_FigurizerP(mSets, mss_rej, stats)];
  end;
  