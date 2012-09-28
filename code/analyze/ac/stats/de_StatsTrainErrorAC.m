function [te] = de_StatsTrainErrorAC(models)
%function [te] = de_StatsTrainErrorAC(LS)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% err           :


  
  te = cell(length(models), 1);
  
  for s=1:length(models)
    ac   = [models{s}.ac];
    te{s} = [ac.trainingError]';
  end;  
