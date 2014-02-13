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

    for zz=1:mSets.runs
        randState = mSets.ac.randState + (zz-1);


        % Can specify multiple mu & sigma,
        %   but one of them must be 1 value,
        %   or they both must be of the same size
        if (length(mSets.mu) > 1 && length(mSets.sigma) > 1 ...
            && length(mSets.mu) ~= length(mSets.sigma))
          error('mu & sigma must match!');
        end;


        niters = max( length(mSets.mu), length(mSets.sigma) );

        for ii=1:niters

            new_model           = de_CopyModelSettings(model, ii);
            new_model.hemi      = ii;

            % Generate randState for ac
            new_model.ac.randState = randState;
            if isfield(model.ac, 'ct'), new_model.ac.ct.ac.randState = randState; end;
            rand ('state',new_model.ac.randState);

            fprintf('[%3d]',zz);
            models(zz,ii) = de_Trainer(new_model);
            if (~models(zz,ii).ac.cached), fprintf('\n'); end;
        end;  %zz
    end;

    fprintf('\n');

function new_model = de_CopyModelSettings(model, mi)

    new_model = guru_rmfield(model, 'p');  % creates a copy, due to MATLAB's lazy-pass-by-value procedure

    flds = { 'mu', 'sigma', 'nHidden', 'hpl', 'nConns', ...
               'ac.EtaInit', 'ac.Acc', 'ac.Dec', 'ac.lambda', ...
               'uberpath', 'out.dirstem', 'out.runspath', 'out.resultspath' ...
    };

    for fi=1:length(flds)
        if ~guru_isfield(model, flds{fi}), continue; end;

        field_vals = guru_getfield(model, flds{fi}, NaN);

        if length(field_vals) == 1
            new_model = guru_setfield(new_model, flds{fi}, field_vals);
        elseif iscell(field_vals)
            new_model = guru_setfield(new_model, flds{fi}, field_vals{mi});
        else
            new_model = guru_setfield(new_model, flds{fi}, field_vals(mi));
        end;
    end;
