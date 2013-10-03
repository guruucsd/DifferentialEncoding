function new_models = de_ContinueModels(models, expt, stimSet, taskType, opt)
    mSets = models(1);

    % Do what's necessary to make the models re-trainable.
    for ii=1:numel(models)
        new_models(ii) = de_LoadProps(models(ii), 'ac', 'Weights');
        new_models(ii).ac.Conn = sparse(new_models(ii).ac.Weights ~= 0);

        new_models(ii).ac.continue = true;
        new_models(ii).p.continue  = false;
        
        new_models(ii).ac.cached = false;
        new_models(ii).p.cached  = false;
    end;
    
    % Now, run!
    tic;
  
    if (~iscell(opt)),             opt      = {opt};     end;
  
    %%%%%%%%%%%%%%%%%
    % Setup
    %%%%%%%%%%%%%%%%%
  
    % This function calls generic functions that are implemented / overwritten
    %   by particular experiments.  Add the path to the current experiment, so that
    %   it's functions are the ones run.
    de_SetupExptPaths(expt);
  
    % Go from args to model settings
    dataFile = de_MakeDataset(expt, stimSet, taskType, opt);

    % Initialize model settings.
    [new_models.expt] = deal(repmat(expt, [numel(new_models) 1]));
    
    %%%%%%%%%%%%%%%%%
    % Training
    %%%%%%%%%%%%%%%%%
  
    % Train autoencoders
    if (mSets.parallel)
    
    else
        for zz=1:numel(new_models)
            % Generate randState for ac
            rand ('state',new_models(zz).ac.randState);
            
            fprintf('[%3d]',zz);
            new_models(zz) = de_Trainer(new_models(zz));
        end;
    end;
    
    % Train classifiers
    if (isfield(mSets, 'p'))
        if (mSets.parallel),   [new_models]      = de_TrainAllP_parallel (new_models);
        else,                  [new_models]      = de_TrainAllP          (new_models); end;
    end;

    %%%%%%%%%%%%%%%%%
    % Analysis
    %%%%%%%%%%%%%%%%%
  
    % Show model summary
    if (ismember(1,mSets.debug))
      fprintf(de_modelSummary(mSets));    % Show AC & P settings
    end;
  
    % Analyze the results
    [stats, figs] = de_Analyzer(mSets, new_models); 

    % Save these off
    [s,mSets]     = de_SaveAll(mSets, new_models, stats, figs);

    toc
