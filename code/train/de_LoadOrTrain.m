function model = de_LoadOrTrain(model)
%
% Figures out whether ac or p needs to be trained.
%   If so, trains 'em up
%   If not, loads results metadata from disk
% Output model is the 'clean' version without 'heavy' props
%
% How to do attentional training:
%   * Try to load with flags.
%   * If that fails, then load without the flags, then pass in (how to indicate to skip first training?).

  % Force the separate training of the non-task-based images
  if isfield(model.ac, 'retrain_on_task_images') && model.ac.retrain_on_task_images
      guru_assert(strcmp(model.deType, 'de'), 'retrain_on_task_images is only supported currently for the de training type.');

      % Just load/train on the previous autoencoder result
      pre_train_model = guru_rmfield(model, 'p');
      pre_train_model.ac.retrain_on_task_images = false;
      pre_train_model = de_LoadOrTrain(pre_train_model);

      % Now load/train on the full thing
      model.ac = pre_train_model.ac;
      model.ac.retrain_on_task_images = true;
      model.ac.cached = false;
      model.ac.continue = true;
      %model = guru_rmfield(model, 'uberpath'); % is this necessary?

  %% Load autoencoder weights, if they exist
  elseif (  ~model.ac.continue ...
     && exist(de_GetOutFile(model, 'ac'),         'file') ...
     && exist(de_GetOutFile(model, 'ac.weights'), 'file'))

    model.ac.fn     = de_GetOutFile(model, 'ac');
    try
      prev_model = model;
      model.ac        = guru_loadVars(model.ac.fn, 'ac');
      model.ac.continue = prev_model.ac.continue;
      if ~strcmp(de_GetOutPath(model, 'ac'), de_GetOutPath(prev_model, 'ac'))
        prev_model.ac, model.ac
        model = prev_model;
        error('properties somehow differ between model properties and loaded model. Examine the two above to understand deeper.');
      end;
      clear('prev_model');
      model.ac.cached = true;
    catch err
      warning(err.message);
      model.ac.cached = false;
    end;

    try
      if (exist(de_GetOutFile(model,'ac.err'),   'file')), model.ac.err    = guru_loadVars(de_GetOutFile(model,'ac.err'), 'err'); end;
      if (~isfield(model, 'uberpath'))
          if (exist(de_GetOutFile(model,'ac.output'),'file')), model.ac.output = guru_loadVars(de_GetOutFile(model,'ac.output'),'output'); end;
          if (exist(de_GetOutFile(model,'ac.hu'),    'file')), model.ac.hu     = guru_loadVars(de_GetOutFile(model,'ac.hu'),'hu'); end;
      end;
    catch err
      % ignore errors.
      warning(err.message);
    end;

    % The "uber" variables don't necessarily correspond to the current variables,
    %   so these outputs may be invalid.  Remove them to make sure they're re-calculated.
    % How to deal with uber options vs our options (i.e. dnw)?
    if (isfield(model, 'uberpath'))
       model.ac = guru_rmfield(model.ac,'hu');
       model.ac = guru_rmfield(model.ac,'output');
    end;

  elseif (isfield(model, 'uberpath'))
    error('Uberfile %s not found.', de_GetOutFile(model, 'ac'));

  % Gotta train...
  else
    model.ac.cached = false;
  end;

  % Load perceptron, if exists
  if ~isfield(model, 'p')
    % nothing, but allows to unindent the following code ;)
  elseif (model.p.continue ...
          || ~exist(de_GetOutFile(model, 'p'),          'file') ...
          || ~exist(de_GetOutFile(model, 'p.weights'),  'file'))
    model.p.cached = false;

  else
    try
      prev_model = model;
      model.p = guru_loadVars(de_GetOutFile(model, 'p'),  'p');
      if de_GetOutPath(model, 'p') ~= de_GetOutPath(prev_model, 'p')
        prev_model.p, model.p
        model = prev_model;
        error('properties somehow differ between model properties and loaded model. Examine the two above to understand deeper.');
      end;
      clear('prev_model');
      model.p.cached = true;
    catch err
      warning(err.message);
      model.p.cached = false;
    end;
  end;

  switch (model.deType)
    case 'de',         model = de_DE     (model);
    case 'de-deep',    model = de_DE_Deep(model);
    case 'de-mtl',     model = de_DE_MTL(model);
    case 'de-stacked', model = de_DE_Stacked(model);
    otherwise, error('Unknown DE type: %s', model.deType);
  end;

  % Stamp filename
  if (~isfield(model.ac,'fn'))
      model.ac.fn = de_GetOutFile(model, 'ac');
  end;

  % Report total time
  trainTime = 0;
  if ~model.ac.cached, trainTime = trainTime + model.ac.trainTime(end); end;
  if isfield(model, 'p') && ~model.p.cached,  trainTime = trainTime + model.p.trainTime(end);  end;
