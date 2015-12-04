function [LS_permodel, LS_mean, LS_stde, LS_pval] = de_models2LS(models, errorType)
%
% models : NxM matrix of models, N=runs, M=nSigmas
%
% LS     : the LS matrix we all know so well

  if (~exist('errorType','var')), errorType=1; end;

  if (iscell(models))
    mSets = models{1}(1);

    LS_permodel = cell(length(models),1);
    LS_mean     = cell(length(models),1);
    LS_stde     = cell(length(models),1);
    LS_pval     = cell(length(models),1);
    for i=1:length(models)
      [LS_permodel{i}, LS_mean{i}, LS_stde{i}] = de_internalGetLS(models{i}, errorType);
    end;

  else
    mSets = models(1);

    LS_permodel = cell(size(models,2),1);
    LS_mean     = cell(size(models,2),1);
    LS_stde     = cell(size(models,2),1);
    LS_pval     = cell(size(models,2),1);
    for i=1:size(models,2)
      [LS_permodel{i}, LS_mean{i}, LS_stde{i}] = de_internalGetLS(models(:,i), errorType);
    end;
  end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [LS_permodel,LS_mean,LS_stde] = de_internalGetLS(models, errorType)
  %
    if (isempty(models))
      LS_permodel = [];
      LS_mean = [];
      LS_stde = [];
      LS_pval = [];
      return;
    end;

    mSets = models(1);
    p     = [models.p];
    runs  = length(models);
    tmp   = de_calcPErr( vertcat(p.lastOutput), mSets.data.train.T, errorType );

    % Calc ls for each model
    LS_permodel      = zeros(runs, length(mSets.data.train.TIDX));
    for j = 1:length(mSets.data.train.TIDX)
      if (~isempty(mSets.data.train.TIDX{j}))
        LS_permodel(:,j) = mean(tmp(:,mSets.data.train.TIDX{j}),2); %average over each sub-trial type
      else
        LS_permodel(:,j) = NaN(size(LS_permodel(:,j)));
      end;
    end;

    % Calc mean, stde for each type
    LS_mean  = zeros(length(mSets.data.train.TIDX),1);
    LS_stde  = zeros(length(mSets.data.train.TIDX),1);
    for j=1:length(mSets.data.train.TIDX)
      x      = tmp(:,mSets.data.train.TIDX{j});
      x      = reshape(x,[prod(size(x)) 1]);
      LS_mean(j) = mean(x);
      LS_stde(j) = guru_stde(x);
    end;

