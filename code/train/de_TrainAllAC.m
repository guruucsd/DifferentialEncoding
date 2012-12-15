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
    
    model        = mSets;

    % Train the networks
    fprintf('Training autoencoder %dD networks: mu=%s, o=%s, nConns=%s, nHidden=%s, trials=%s\n', ...
            length(model.nInput),...
            ['[ ' sprintf('%3.1f ',model.mu) ']'], ...
            ['[ ' sprintf('%3.1f ',model.sigma) ']'], ...
            ['[ ' sprintf('%2d ',  model.nConns) ']'], ...
            ['[ ' sprintf('%3d ',  model.nHidden) ']'], ...
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

        for i=1:niters
            
            new_model           = guru_rmfield(model, 'p');
            
            % Generate randState for ac
            new_model.ac.randState = randState;
            rand ('state',new_model.ac.randState);
            
            
            % Parse out ACTUAL model settings
            if length(mSets.mu)==1,  new_model.mu = mSets.mu;
            else,                    new_model.mu = mSets.mu(i);
            end;
            
            if length(mSets.sigma)==1,  new_model.sigma = mSets.sigma;
            else,                       new_model.sigma = mSets.sigma(i);
            end;
            
            if length(mSets.nHidden)==1, new_model.nHidden = mSets.nHidden;
            else,                        new_model.nHidden = mSets.nHidden(i);
            end;
            
            if length(mSets.hpl)==1,     new_model.hpl = mSets.hpl;
            else,                        new_model.hpl = mSets.hpl(i);
            end;
            
            if length(mSets.nConns)==1,  new_model.nConns = mSets.nConns;
            else,                        new_model.nConns = mSets.nConns(i);
            end;
            
            if length(mSets.ac.EtaInit)==1, new_model.ac.EtaInit = mSets.ac.EtaInit;
            else,                           new_model.ac.EtaInit = mSets.ac.EtaInit(i);
            end;
            
            if length(mSets.ac.Acc)==1, new_model.ac.Acc = mSets.ac.Acc;
            else,                       new_model.ac.Acc = mSets.ac.Acc(i);
            end;
            
            if length(mSets.ac.Dec)==1, new_model.ac.Dec = mSets.ac.Dec;
            else,                       new_model.ac.Dec = mSets.ac.Dec(i);
            end;
            
            if length(mSets.ac.lambda)==1, new_model.ac.lambda = mSets.ac.lambda;
            else,                          new_model.ac.lambda = mSets.ac.lambda(i);
            end;
            
            if (isfield(mSets, 'uberpath'))
            if length(mSets.uberpath)==1,  new_model.uberpath = mSets.uberpath;
            else,                          new_model.uberpath = mSets.uberpath{i};
            end; end;
            
            
            fprintf('#%-4d',zz);
            models(zz,i) = de_Trainer(new_model);
            fprintf('\n');
        end;  %zz
    end;