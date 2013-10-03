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
  