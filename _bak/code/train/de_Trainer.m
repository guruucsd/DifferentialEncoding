function [model] = de_Trainer(model)
%[models] = de_Trainer(mSets, model)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% models     : a model object for each trained model, with properties
%              specifying training parameters, final weights, training errors, etc.
  

    % Load up a cached version, if it exists
    model = de_LoadOrTrain(model);

    model = de_CompressAndSave(model);
