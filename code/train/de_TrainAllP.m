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

  for mm=1:numel(modelsAC)
    randState = mSets.p.randState;

    model = modelsAC(mm);
    model.p = mSets.p; % re-stamp the p settings!

    pis = mSets.p.AvgError;   pas=mSets.p.Acc;
    pes = mSets.p.EtaInit;    pds=mSets.p.Dec;

    for pi=1:length(pis), for pa=1:length(pas)
    for pe=1:length(pes), for pd=1:length(pds)
        model.p.AvgError  = pis(pi);   model.p.Acc = pas(pa);
        model.p.EtaInit   = pes(pe);   model.p.Dec = pds(pd);

        % Generate randState for ac
        model.p.randState = randState;
        rand ('state',model.p.randState);


        fprintf('[%3d]',mm);
        models(mm,pd,pe,pa,pi) = de_Trainer(model);
        if (~models(mm,pd,pe,pa,pi).p.cached), fprintf('\n'); end;

        %% CRITICAL: UPDATE THE RANDOM STATE!!
        randState = randState + 1;
      end; end; %pd, pe
      end; end; %pa, pi
  end;

  models = reshape(models, [size(modelsAC) squeeze(size(models(1,:,:,:,:)))]);