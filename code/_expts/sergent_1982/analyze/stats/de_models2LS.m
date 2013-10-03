function [LS_permodel, LS_mean, LS_stde, LS_pval] = de_models2LS(models, errorType)
%
% models : NxM matrix of models, N=rons, M=nSigmas
%
% LS     : the LS matrix we all know so well
  
  if (~exist('errorType','var')), errorType=1; end;

  if (~iscell(models))
    mss = cell(size(models,2));
    for si=1:length(mss), mss{si} = models(:,si); end;
    models = mss;
  end;
   
    LS_permodel = cell(length(models),1);
    LS_mean     = cell(length(models),1);
    LS_stde     = cell(length(models),1);
    LS_pval     = cell(length(models),1);
    for i=1:length(models)
      [LS_permodel{i}, LS_mean{i}, LS_stde{i}] = de_internalGetLS(models{i}, errorType);
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
    rons  = length(models);

    p     = [models.p];
    o     = [p.output];
    o_p   = reshape(horzcat(o.test),[numel(o(1).test),length(o)])';
    tmp   = de_calcPErr( o_p, mSets.data.test.T, errorType );
        
    % Calc ls for each model      
    ndupes = size(o_p,2)/length(mSets.data.train.ST);
    allidx = cell(length(mSets.data.train.TIDX));
    LS_permodel      = zeros(rons, length(mSets.data.train.TIDX));
    for j = 1:length(mSets.data.train.TIDX)
      if (~isempty(mSets.data.train.TIDX{j}))
        allidx{j} = repmat(mSets.data.train.TIDX{j},[ndupes 1]) .* repmat(1:ndupes, [length(mSets.data.train.TIDX{j}) 1])';
        LS_permodel(:,j) = mean(tmp(:,allidx{j}(:)),2); %average over each sub-trial type
      else
        LS_permodel(:,j) = NaN(size(LS_permodel(:,j)));
      end;
    end;
    
    % Calc mean, stde for each type
    LS_mean  = zeros(length(mSets.data.train.TIDX),1);
    LS_stde  = zeros(length(mSets.data.train.TIDX),1);
    for j=1:length(mSets.data.train.TIDX)
      x      = tmp(:,allidx{j}(:));
      LS_mean(j) = mean(x(:));
      LS_stde(j) = guru_stde(x(:));
    end;

    
