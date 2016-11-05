function newModels = de_ContinueModels(models, expt, stimSet, taskType, opt)
% Preliminary code for training models that were created via developmental pruning.

    mSets = models(1);

    % Do what's necessary to make the models re-trainable.
    for ii=1:numel(models)
        newModels(ii) = de_LoadProps(models(ii), 'ac', 'Weights');
        newModels(ii).ac.Conn = sparse(newModels(ii).ac.Weights ~= 0);

        newModels(ii).ac.continue = true;
        newModels(ii).p.continue  = false;

        newModels(ii).ac.cached = false;
        newModels(ii).p.cached  = false;
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
    [newModels.expt] = deal(repmat(expt, [numel(newModels) 1]));

    %%%%%%%%%%%%%%%%%
    % Training
    %%%%%%%%%%%%%%%%%

    % Train autoencoders
    parfor zz=1:numel(newModels)
        % Generate randState for ac
        rand ('state',newModels(zz).ac.randState);

        fprintf('[%3d]',zz);
        newModels(zz) = de_Trainer(newModels(zz));
    end;

    % Train classifiers
    [newModels]      = de_TrainAllP          (newModels);

    %%%%%%%%%%%%%%%%%
    % Analysis
    %%%%%%%%%%%%%%%%%

    % Show model summary
    if (ismember(1,mSets.debug))
      fprintf(de_modelSummary(mSets));    % Show AC & P settings
    end;

    % Analyze the results
    [stats, figs] = de_Analyzer(mSets, newModels);

    % Save these off
    [s,mSets]     = de_SaveAll(mSets, newModels, stats, figs);

    toc
