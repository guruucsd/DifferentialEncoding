function [models] = de_TrainAllAC_parallel(m)
%[models] = de_TrainAllAC_parallel(m)
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
    
    mSets = m(1);
    
    % Train the networks
    fprintf('Training autoencoder %dD networks: mu=%s, o=%s, nConns=%s, nHidden=%s, trials=%s\n', ...
            length(mSets.nInput),...
            ['[ ' sprintf('%3.1f ',mSets.mu) ']'], ...
            ['[ ' sprintf('%3.1f ',mSets.sigma) ']'], ...
            ['[ ' sprintf('%2d ',  mSets.nConns) ']'], ...
            ['[ ' sprintf('%3d ',  mSets.nHidden) ']'], ...
            ['[ ' sprintf('%3d ',  mSets.runs) ']'] );


    %----------------
    % Loop over sigmas and trials
    %   (to collect enough samples)
    %----------------
    if (numel(m)==1), nruns = mSets.runs; else, nruns = numel(m); end;
    
    parfor zz=1:nruns
        randState = mSets.ac.randState + (zz-1);

        if (numel(m)==1)
            model = mSets;
        else
            model = m(zz);
        end;
        
        % Can specify multiple mu & sigma,
        %   but one of them must be 1 value,
        %   or they both must be of the same size
        if (length(mSets.mu) > 1 && length(mSets.sigma) > 1 ...
            && length(mSets.mu) ~= length(mSets.sigma))
          error('mu & sigma must match!');
        end;


        niters = max( length(mSets.mu), length(mSets.sigma) );

        for ii=1:niters
            
            new_model           = guru_rmfield(model, 'p');
            new_model.hemi      = ii;
            
            % Generate randState for ac
            new_model.ac.randState = randState;
            if isfield(new_model.ac, 'ct'), new_model.ac.ct.ac.randState = randState; end;
            rand ('state',new_model.ac.randState);
            fprintf('xxx randState: %d\n', new_model.ac.randState);
            
            % Parse out ACTUAL model settings
            if length(mSets.mu)==1,  new_model.mu = mSets.mu;
            else,                    new_model.mu = mSets.mu(ii);
            end;
            
            if length(mSets.sigma)==1,  new_model.sigma = mSets.sigma;
            else,                       new_model.sigma = mSets.sigma(ii);
            end;
            
            if length(mSets.nHidden)==1, new_model.nHidden = mSets.nHidden;
            else,                        new_model.nHidden = mSets.nHidden(ii);
            end;
            
            if length(mSets.hpl)==1,     new_model.hpl = mSets.hpl;
            else,                        new_model.hpl = mSets.hpl(ii);
            end;
            
            if length(mSets.nConns)==1,  new_model.nConns = mSets.nConns;
            else,                        new_model.nConns = mSets.nConns(ii);
            end;
            
            if length(mSets.ac.EtaInit)==1, new_model.ac.EtaInit = mSets.ac.EtaInit;
            else,                           new_model.ac.EtaInit = mSets.ac.EtaInit(ii);
            end;
            
            if length(mSets.ac.Acc)==1, new_model.ac.Acc = mSets.ac.Acc;
            else,                       new_model.ac.Acc = mSets.ac.Acc(ii);
            end;
            
            if length(mSets.ac.Dec)==1, new_model.ac.Dec = mSets.ac.Dec;
            else,                       new_model.ac.Dec = mSets.ac.Dec(ii);
            end;
            
            if length(mSets.ac.lambda)==1, new_model.ac.lambda = mSets.ac.lambda;
            else,                          new_model.ac.lambda = mSets.ac.lambda(ii);
            end;
            
            if (isfield(mSets, 'uberpath'))
            if length(mSets.uberpath)==1,  new_model.uberpath = mSets.uberpath;
            else,                          new_model.uberpath = mSets.uberpath{ii};
            end; end;
            
            
            fprintf('[%3d]',zz);
            mtmp = de_Trainer(new_model);
            if (~mtmp.ac.cached), fprintf('\n'); end;
        end;  %zz
    end;
    
      
  % This will LOAD the models
  fprintf('[Loading...]');
  models = de_TrainAllAC(mSets);
  fprintf('[loading done.]\n');
