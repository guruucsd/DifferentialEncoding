function [ti] = de_StatsTrainIters(models)
%function [ti] = de_StatsTrainIters(models)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% ti : # of training iterations

  % calc learning error  
  if (isstruct(models))
    models = mat2cell(models, size(models,1), ones(size(models,2),1));
  end;
  
  ti.AC = cell(length(models), 1);
  ti.P = cell(length(models), 1);
  
  for s=1:length(models)
    ac = [models{s}.ac];
    p  = [models{s}.p];
    
    ti.AC{s} = [ac.Iterations]';
    ti.P{s}  = [p.Iterations]';
  end;
  
