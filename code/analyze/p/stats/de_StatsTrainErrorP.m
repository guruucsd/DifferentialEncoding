function [te, pval] = de_StatsTrainErrorP(models)
%function [te, pval] = de_StatsErrP(LS)
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
      if isempty(models{s}), continue; end;
      te{s} = arrayfun(@(m) m.p.trainingError, models{s});
  end;


  % Test for significance
  if (length(models)~=2)
    pval = NaN;
  else
    x=[]; g={};
    for i=1:length(models)
      x = [x;te{i}];
      tmp = guru_csprintf('%i', num2cell(repmat(i,size(te{i}))));
      g = [g tmp];
    end;
    [pval] = anovaSRV(x,g', 'off');  % '
  end;
