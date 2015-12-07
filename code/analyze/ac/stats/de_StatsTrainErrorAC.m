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
    te{s} = arrayfun(@(m) m.ac.trainingError, models{s});
  end;
