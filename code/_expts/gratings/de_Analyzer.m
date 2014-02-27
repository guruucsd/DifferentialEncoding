function [stats, figs]  = de_AnalyzerSF(mSets, mss)
%function [stats, figs]  = de_AnalyzerSF(mSets, mss)
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
%  [stats.raw.r] = de_FindRejectionsRF(mss, mSets.rej, stats.raw, stats.raw.r);
  [mss]        = de_DoRejections(mss, stats.raw.r);

  % Do SF-specific stats & figs
  [stats.rej.sf] = de_StaticizerRF(mSets, mss, stats);
  [figs]         = [figs de_FigurizerRF(mSets, mss, stats) ];


