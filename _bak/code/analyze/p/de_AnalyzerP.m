function [stats, figs]  = de_AnalyzerDE(mSets, mss)
%function [stats, figs]  = de_AnalyzerDE(mSets, mss)
%
% Analyzes the differential encoder models with the most generic methods
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
  
  if (ismember(1,mSets.debug))
    fprintf(de_modelSummary(mSets));    % Show AC & P settings
  end;
 
  %  Do the analyses
  [stats.raw] = de_StaticizerDE(mSets, mss);
  [figs]      = de_FigurizerDE(mSets, mss, stats);
  
