function [stats, figs]  = de_AnalyzerKit(mSets, mss)
%function [stats, figs]  = de_AnalyzerKit(mSets, mss)
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
%  [stats.raw.r] = de_FindRejectionsKit(mss, mSets.rej, stats.raw, stats.raw.r);
  [mss]        = de_DoRejections(mss, stats.raw.r);

  % Do Kit-specific stats & figs
  [stats.rej.sf] = de_StaticizerKit(mSets, mss, stats);
  [figs]         = [figs de_FigurizerKit(mSets, mss, stats) ];


