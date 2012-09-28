function [ti] = de_StatsTrainItersP(models)
%function [ti] = de_StatsTrainItersP(models)
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
  
  ti = cell(length(models), 1);
  
  for s=1:length(models)
      p  = [models{s}.p];
      ti{s}  = [p.Iterations]';
  end;
