function [LS_permodel, LS_mean, LS_stde, LS_raw_permodel] = de_models2LS(models, errorType)
%
% models : NxM matrix of models, N=runs, M=nSigmas
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
    LS_raw_permodel = cell(length(models),1);
    for i=1:length(models)
      [LS_permodel{i}, LS_mean{i}, LS_stde{i}, LS_raw_permodel{i} ] = de_internalGetLS(models{i}, errorType);
    end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [LS_permodel, LS_mean, LS_stde, LS_raw_permodel] = de_internalGetLS(models, errorType)
  %
    if (isempty(models))
      LS_permodel = [];
      LS_mean = [];
      LS_stde = [];
      return;
    end;


    mSets = models(1);
    runs  = length(models);
    num_trial_types =length(mSets.data.train.TIDX);
    raw_error = zeros(runs, length(mSets.data.test.T));
    for mi=1:runs
      [oact] = guru_nnExec(models(mi), mSets.data.test.X, mSets.data.test.T);
      raw_error(mi, :) = de_calcPErr( oact, mSets.data.test.T, errorType );        % # models x # trials
    end;

    % Calc ls for each model
    ndupes           = size(oact, 2) / length(mSets.data.test.ST);  % sometimes we duplicate outputs for training, for fun.
    allidx           = cell(num_trial_types, 1);
    LS_permodel      = zeros(runs, num_trial_types);
    LS_raw_permodel  = cell(runs, num_trial_types);

    for j = 1:num_trial_types
      if (~isempty(mSets.data.train.TIDX{j}))
        % get trial indices for this trial type
        allidx{j} = repmat(mSets.data.train.TIDX{j},[ndupes 1]) .* repmat(1:ndupes, [length(mSets.data.train.TIDX{j}) 1])';

        % grab those trials, for all models, and shove into data structures.
        cur_trials = raw_error(:,allidx{j}(:));
        LS_raw_permodel(:, j) = num2cell(cur_trials, 2);
        LS_permodel(:, j) = mean(cur_trials, 2); %average over each sub-trial type
      else
        LS_raw_permodel(:, j) = repmat({[]}, [runs 1]);
        LS_permodel(:, j) = NaN(size(LS_permodel(:,j)));
      end;
    end;

    % Calc mean, stde for each type
    LS_mean  = zeros(num_trial_types, 1);
    LS_stde  = zeros(num_trial_types, 1);
    for j=1:num_trial_types
      LS_mean(j) = mean(LS_permodel(:, j));
      LS_stde(j) = guru_stde(LS_permodel(:, j));
    end;
