function [models] = de_TrainAllAC(mSets)
%[models] = de_TrainAllAC(mSets)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% mSets      : see de_model for details
%
% Outputs:
% models     : a model object for each trained model, with properties
%              specifying training parameters, final weights, training errors, etc.

    %----------------
    % Loop over architecture variables
    %   (if testing "robustness" of model)
    %----------------

    model = mSets;

    % Train the networks
    fprintf('Training autoencoder %dD networks: mu=%s, o=%s, nConns=%s, nHidden=%s, trials=%s\n', ...
            length(model.nInput),...
            ['[ ' sprintf('%3.1f ',mSets.mu) ']'], ...
            ['[ ' sprintf('%3.1f ',mSets.sigma) ']'], ...
            ['[ ' sprintf('%2d ',  mSets.nConns) ']'], ...
            ['[ ' sprintf('%3d ',  mSets.nHidden) ']'], ...
            ['[ ' sprintf('%3d ',  mSets.runs) ']'] );


    %----------------
    % Loop over sigmas and trials
    %   (to collect enough samples)
    %----------------
    nhemis = max( length(mSets.mu), length(mSets.sigma) );
    models = cell(mSets.runs, nhemis);

    try
        parfor zz=1:mSets.runs
            randState = mSets.ac.randState + (zz-1);


            % Can specify multiple mu & sigma,
            %   but one of them must be 1 value,
            %   or they both must be of the same size
            if (length(mSets.mu) > 1 && length(mSets.sigma) > 1 ...
                && length(mSets.mu) ~= length(mSets.sigma))
              error('mu & sigma must match!');
            end;



            for ii=1:nhemis

                newModel           = de_CopyModelSettings(model, ii);
                newModel.hemi      = ii;

                % Generate randState for ac
                newModel.ac.randState = randState;
                if isfield(model.ac, 'ct'), newModel.ac.ct.ac.randState = randState; end;
                rand ('state',newModel.ac.randState);

                fprintf('[%3d]',zz);
                newModel = de_Trainer(newModel);
                if (~newModel.ac.cached), fprintf('\n'); end;

                % Save
                models{zz,ii} = newModel;
            end;  %zz
        end;
    catch
        rethrow(lasterror())
    end;

    fprintf('\n');

    models = cell2mat(models);
