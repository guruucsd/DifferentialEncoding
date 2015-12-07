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
      if isempty(models{s}), continue; end;
      ti{s} = arrayfun(@(m) m.p.Iterations, models{s});
  end;
