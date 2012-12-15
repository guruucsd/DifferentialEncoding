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
  
  nc = mSets.nConns; nh = mSets.nHidden;
  for cc=1:length(nc), for hh=1:length(nh)
    model        = mSets;
    model.nConns = nc(cc); model.nHidden = nh(hh);

    %----------------
    % Loop over training parameters
    %   (to search parameter space)
    %----------------
    acis = mSets.ac.AvgError; acas=mSets.ac.Acc; 
    aces = mSets.ac.EtaInit;  acds=mSets.ac.Dec;
    
    for aci=1:length(acis), for aca=1:length(acas)
    for ace=1:length(aces), for acd=1:length(acds)
       
        model.ac.AvgError = acis(aci); model.ac.Acc = acas(aca);
        model.ac.EtaInit  = aces(ace); model.ac.Dec = acds(acd);

        % Train the networks
        fprintf('Training autoencoder %dD networks: mu=%s, o=%s, nConns=%d, nHidden=%d, trials=%d\n', ...
                length(model.nInput),...
                ['[' sprintf('%4.1f ',model.mu) ']'], ...
                ['[' sprintf('%4.1f ',model.sigma) ']'], ...
                model.nConns, model.nHidden, mSets.runs);

  
        %----------------
        % Loop over sigmas and trials
        %   (to collect enough samples)
        %----------------
        randState = mSets.ac.randState;

        for zz=1:mSets.runs

 
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


            % Parse out ACTUAL model settings
            if length(mSets.mu)==1,  new_model.mu = mSets.mu;
            else,                    new_model.mu = mSets.mu(i);
            end;

            if length(mSets.sigma)==1,  new_model.sigma = mSets.sigma;
            else,                       new_model.sigma = mSets.sigma(i);
            end;

            if length(mSets.ac.EtaInit)==1, new_model.ac.EtaInit = mSets.ac.EtaInit;
            else,                           new_model.ac.EtaInit = mSets.ac.EtaInit(i);
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

            % Generate randState for ac
            new_model.ac.randState = randState;
            rand ('state',new_model.ac.randState);
            
            fprintf('#%-4d',zz);
            models(zz,i,acd,ace,aca,aci,cc,hh) = de_Trainer(new_model);
            fprintf('\n');


            %% CRITICAL: UPDATE THE RANDOM STATE!!
            randState = randState + 1;      
          end;  %ss
    %    end; %mm
      end; %runs
          
    end; end; %acd, %ace
    end; end; %aca, aci
    
  end; end; %hh,cc
