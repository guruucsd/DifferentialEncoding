function model = de_LoadOrTrain(model)
%
% Figures out whether ac or p needs to be trained.
%   If so, trains 'em up
%   If not, loads results metadata from disk
% Output model is the 'clean' version without 'heavy' props
%
  % Load autoencoder, if exists

  % Load autoencoder OUTPUT, if it exists
  if ( isfield(model, 'uber'))
      if (exist(de_GetUberFile(model, 'ac'),         'file') ...
       && exist(de_GetUberFile(model, 'ac.weights'), 'file') ...
       && exist(de_GetUberFile(model, 'ac.err'),     'file'))
  
          model.ac        = guru_loadVars(de_GetUberFile(model, 'ac'), 'ac');
          model.ac.cached = 1;

          keyboard
      else
          error('"Uber" specified, but required "uber" file is not found. :/');
      end;
      
  elseif (exist(de_GetOutFile(model, 'ac'),         'file') ...
       && exist(de_GetOutFile(model, 'ac.weights'), 'file') ...
       && exist(de_GetOutFile(model, 'ac.err'),     'file'))
      
    model.ac        = guru_loadVars(de_GetOutFile(model, 'ac'), 'ac');
    model.ac.cached = 1;
    
      
  % Gotta train...
  else
    model.ac.cached = 0;
  end;
  
  % Load perceptron, if exists
  if (isfield(model, 'p'))
      if (   exist(de_GetOutFile(model, 'p'),          'file') ...
          && exist(de_GetOutFile(model, 'p.weights'),  'file') ...
          && exist(de_GetOutFile(model, 'p.output'),   'file'))
        model.p        = guru_loadVars(de_GetOutFile(model, 'p'),  'p');
        model.p.cached = 1;
      else
        model.p.cached = 0;
      end;
  end;
  
  switch (model.deType)
    case 'de',         model = de_DE    (model);
    case 'de-mtl',     model = de_DEMTL (model);
    case 'de-compact', model = model;
    otherwise, error('Unknown DE type: %s', model.deType);
  end;
 
  % Report total time
  trainTime = 0;
  if (model.ac.cached == 0), trainTime = trainTime + model.ac.trainTime; end;
  if (isfield(model, 'p') && model.p.cached == 0),  trainTime = trainTime + model.p.trainTime;  end;
  
  fprintf(' | t: %5.1fs (%5.1fs', trainTime, model.ac.trainTime);
  if (isfield(model, 'p')), fprintf('+ %5.1fs', model.p.trainTime); end;
  fprintf(')');
  