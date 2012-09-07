function [stats, figs]  = de_DEAnalyzerLSB(mSets, mss)
%function [stats, figs]  = de_DEAnalyzerLSB(mSets, mss)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% models   : resulting models after training
%
% Outputs:
% stats      : 
% figs       : 

  % Log the mapping between settings and integer to a text file,
  %   so we can easily look for this mapping later
  de_LogSettingsMap(mSets);
  
  %  Do the analyses
  mss = num2cell(mss,1);
  [stats.raw] = de_DEStaticizer(mSets, mss);
  [stats.rej] = de_DEStaticizer(mSets, mss);
  [figs]      = de_DEFigurizer(mSets, mss, stats);
  
 
  [stats]     = de_DEStaticizerLSB(mSets, mss, stats);
  [figs]      = de_DEFigurizerLSB(mSets, mss, stats, figs);

  
