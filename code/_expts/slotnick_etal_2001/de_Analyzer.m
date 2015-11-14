function [stats, figs]  = de_AnalyzerCC(mSets, mss)
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

  % Do CC-specific stats & figs
  [stats.rej.cc] = de_StaticizerCC(mSets, mss, stats);
  [figs]         = [figs de_FigurizerCC(mSets, mss, stats) ];


