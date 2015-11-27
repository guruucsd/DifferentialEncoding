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
  n_pis = numel(mSets.p.AvgError);
  n_pas = numel(mSets.p.Acc);
  n_pes = numel(mSets.p.EtaInit);
  n_pds = numel(mSets.p.Dec);

  models = cell(n_runs, n_pis, n_pas, n_pes, n_pds);

  try
      for mm=1:n_runs
        randState = mSets.p.randState;

        model = modelsAC(mm);
        model.p = mSets.p; % re-stamp the p settings!

        for pi=1:n_pis, for pa=1:n_pas
        for pe=1:n_pes for pd=1:n_pds
            model.p.AvgError  = pis(pi);   model.p.Acc = pas(pa);
            model.p.EtaInit   = pes(pe);   model.p.Dec = pds(pd);

            % Generate randState for ac
            model.p.randState = randState;
            rand ('state',model.p.randState);

            fprintf('[%3d]',mm);
            models{mm,pd,pe,pa,pi} = de_Trainer(model);
            if (~models{mm,pd,pe,pa,pi}.p.cached), fprintf('\n'); end;

            %% CRITICAL: UPDATE THE RANDOM STATE!!
            randState = randState + 1;
          end; end; %pd, pe
        end; end; %pa, pi
      end;
  catch
    rethrow(lasterror());
  end;

  models = reshape(cell2mat(models), [size(modelsAC) squeeze(size(models(1,:,:,:,:)))]);
