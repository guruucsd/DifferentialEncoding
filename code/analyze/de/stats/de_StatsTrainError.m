function [err] = de_StatsTrainingError(models, errorType)
%function [err] = de_StatsErrP(LS)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% err           :


  % calc learning error  
  if (isstruct(models))
    models = mat2cell(models, size(models,1), ones(size(models,2),1));
  end;
  
  err.AC = cell(length(models), 1);
  err.P = cell(length(models), 1);
  
  for s=1:length(models)
    ac = [models{s}.ac];
    p  = [models{s}.p];
    
    err.AC{s} = [ac.trainingError]';
    err.P{s}  = [p.trainingError]';
  end;  

  % Test for significance
  if (length(models)==2)
    x=[]; g={};
    for i=1:length(models)
      x = [x;err.AC{i}];
      tmp = guru_csprintf('%i', num2cell(repmat(i,size(err.AC{i}))));
      g = {g{:} tmp{:}};
    end;
    [err.AC_p] = anova1(x,g');
  end;