function [stats, figs]  = de_Analyzer(mSets, mss)
%function [stats, figs]  = de_Analyzer(mSets, mss)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% models   : resulting models after training
%
% Outputs:
% stats      : 
% figs       : 
  
  [stats,figs] = de_AnalyzerDE(mSets, mss);
%  [stats.raw.r] = de_FindRejectionsHL(mss, mSets.rej, stats.raw, stats.raw.r);
  [mss]        = de_DoRejections(mss, stats.raw.r);

  [stats] = de_StaticizerHL(mSets, mss, stats);
  [figs]  = [figs de_FigurizerHL(mSets, mss, stats) ];

  
