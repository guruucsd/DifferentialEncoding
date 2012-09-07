function [tt] = de_StatsTrainTime(models)
%function [tt] = de_StatsTrainTime(models)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% tt           :

  % calc learning error  
  if (isstruct(models))
    models = mat2cell(models, size(models,1), ones(size(models,2),1));
  end;
  
  tt.AC = cell(length(models), 1);
  tt.P = cell(length(models), 1);
  
  for s=1:length(models)
    ac = [models{s}.ac];
    p  = [models{s}.p];
    
    tt.AC{s} = [ac.trainTime]';
    tt.P{s}  = [p.trainTime]';
  end;
  
