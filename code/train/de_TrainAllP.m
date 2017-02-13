function [models] = de_TrainAllP(mSets, modelsAC)
%[models] = de_TrainAllP(mSets)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% models     : a model object for each trained model, with properties
%              specifying training parameters, final weights, training errors, etc.

  %----------------
  % Loop over architecture variables
  %   (if testing "robustness" of model)
  %----------------

  % Train the networks
  fprintf('Training classifier %dD networks [uber=%d]: mu=%s, o=%s, nConns=%s, nHidden=%s, trials=%s\n', ...
          length(mSets.nInput),...
          isfield(mSets, 'uberpath'), ...
          ['[ ' sprintf('%3.1f ',mSets.mu) ']'], ...
          ['[ ' sprintf('%3.1f ',mSets.sigma) ']'], ...
          ['[ ' sprintf('%2d ',  mSets.nConns) ']'], ...
          ['[ ' sprintf('%3d ',  mSets.nHidden) ']'], ...
          ['[ ' sprintf('%3d ',  mSets.runs) ']'] );

  n_runs = numel(modelsAC);
  arglens = [ ...
      numel(mSets.p.AvgError), ...
      numel(mSets.p.Acc), ...
      numel(mSets.p.EtaInit), ...
      numel(mSets.p.Dec) ...
  ];
  guru_assert(length(setdiff(unique(arglens), [1])) <= 1, ...
    'Lengths must contain at most one non-unary value.' ...
  );
  n_args = max(arglens);

  models = cell([n_runs, arglens]);

  try
      parfor mi=1:(n_runs * n_args)
        ai = 1 + mod(mi - 1, n_args);
        ri = 1 + ceil(zi / n_args);
        randState = mSets.p.randState;

        model = modelsAC(mi);
        model.p = mSets.p; % re-stamp the p settings!

        model.p.AvgError = mSets.p.AvgError(min(numel(mSets.p.AvgError), ai));
        model.p.Acc = mSets.p.Acc(min(numel(mSets.p.Acc), ai));
        model.p.EtaInit = mSets.p.EtaInit(min(numel(mSets.p.EtaInit), ai));
        model.p.Dec = mSets.p.Dec(min(numel(mSets.p.Dec), ai));

        % Generate randState for ac
        model.p.randState = randState;
        rand ('state', model.p.randState);

        fprintf('[%3d]',mi);
        models{mi} = de_Trainer(model);
        if (~models{mi}.p.cached), fprintf('\n'); end;
      end;
  catch err
    rethrow(err);
  end;

  models = reshape(cell2mat(models), [size(modelsAC) squeeze(size(models(1,:,:,:,:)))]);
