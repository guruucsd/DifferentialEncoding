function [ti, pval] = de_StatsTrainItersAC(models)
%function [ti, pval] = de_StatsTrainItersAC(models)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
%
% Output:
% ti : # of training iterations

  ti = cell(length(models), 1);

  for s=1:length(models)
    ac = [models{s}.ac];
    ti{s} = [ac.Iterations]';
  end;


  % Test for significance
  if (length(models)~=2)
    pval = nan;
  else
    x=[]; g={};
    for i=1:length(models)
      x = [x;ti{i}];
      tmp = guru_csprintf('%i', num2cell(repmat(i,size(ti{i}))));
      g = [g tmp];
    end;
    [pval] = anova1(x,g', 'off');
  end;
