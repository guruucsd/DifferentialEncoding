function [tt] = de_StatsTrainTimeAC(models)
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

  tt = cell(length(models), 1);

  for s=1:length(models)
    tt{s} = arrayfun(@(m) m.ac.trainTime, models{s});
  end;
