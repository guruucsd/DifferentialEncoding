function [stats, figs]  = de_AnalyzerAC(mSets, mss)
%function [stats, figs]  = de_AnalyzerAC(mSets, mss)
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
  [mss]        = de_DoRejections(mss, stats.raw.r);

  % we should be doing something here, no?
  error('mnist-specific analyses NYI');
