function [models] = de_DETrainer(modelSettings, model)
%[models] = de_DETrainer(modelSettings, model)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% models     : a model object for each trained model, with properties
%              specifying training parameters, final weights, training errors, etc.
  
  if (~exist('model','var')), model = modelSettings; end;
  
  % Train the networks
  fprintf('Training %dD networks: o=%s, nConns=%d, nHidden=%d, trials=%d\n', ...
          length(model.nInput), ['[' sprintf('%4.1f ',model.sigma) ']'], ...
          model.nConns, model.nHidden, modelSettings.runs);

    
  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
  randState = modelSettings.randState;
  
  for zz=1:modelSettings.runs
    for ss=1:length(modelSettings.sigma)
      new_model           = rmfield(model, 'randState');
      new_model.sigma     = modelSettings.sigma(ss);
      
      % Generate randStates for ac and p
      new_model.ac.randState = randState;
      rand ('state',new_model.ac.randState);
      new_model.p.randState  = floor(rand()*(2^31-2));
      
      % Load up a cached version, if it exists
      fprintf('#%-4d',zz);
      new_model = de_LoadOrTrain(new_model);
      fprintf('\n');
      
      % Save the results
      if (~exist('models','var'))
        models = de_DECompressAndSave(new_model);
      else
        [models(zz,ss)] = de_DECompressAndSave(new_model);
      end;

      %% CRITICAL: UPDATE THE RANDOM STATE!!
      randState = randState + 1;      
    end;  %ss
  end; %runs
