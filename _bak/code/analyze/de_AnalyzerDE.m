function [stats, figs, mss]  = de_AnalyzerDE(mSets, mss, rej)
%function [stats, figs]  = de_AnalyzerDE(mSets, mss)
%


  % Show model summary
  if (ismember(1,mSets.debug))
    fprintf(de_modelSummary(mSets));    % Show AC & P settings
  end;
  
  % Make cell array
  mss = num2cell(mss, 1);

  % Load cached if they exist; only non-present stats will be rerun
  if (false && exist(de_GetOutFile(mSets, 'stats'), 'file'))
      load( de_GetOutFile(mSets, 'stats'), 'stats' );
  else
      stats = [];
  end;
  figs = de_NewFig('dummy');
  
  
  % Pull out the most basic stats
  [stats.raw.ac]     = de_StaticizerAC(mSets, mss, {'default'});
  if (isfield(mSets,'p'))
      [stats.raw.p]      = de_StaticizerP(mSets, mss, {'default'});
  end;
  
  % Do rejections
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
  [stats.rej.ac] = de_StaticizerAC(mSets, mss_rej);
  [figs]         = [figs de_FigurizerAC(mSets, mss_rej, stats)];

  % Do P generic stats & figs
  if (isfield(mSets, 'p'))
    [stats.rej.p]  = de_StaticizerP(mSets, mss_rej);
    [figs]         = [figs de_FigurizerP(mSets, mss_rej, stats)];
  end;
  