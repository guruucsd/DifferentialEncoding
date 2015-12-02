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
    te{s} = cellfun(@(m) m.ac.trainingError, num2cell(models{s}));
  end;
