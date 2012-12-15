function model = de_LoadOrTrain(model)
%
% Figures out whether ac or p needs to be trained.
%   If so, trains 'em up
%   If not, loads results metadata from disk
% Output model is the 'clean' version without 'heavy' props
%

  % Load autoencoder OUTPUT, if it exists
  if (  exist(de_GetOutFile(model, 'ac'),         'file') ...
     && exist(de_GetOutFile(model, 'ac.weights'), 'file') ...
     && exist(de_GetOutFile(model, 'ac.err'),     'file'))
       
    model.ac.fn     = de_GetOutFile(model, 'ac');
    model.ac        = guru_loadVars(model.ac.fn, 'ac');
    model.ac.cached = 1;
          
  elseif (isfield(model, 'uberpath'))
    error('Uberfile %s not found.', de_GetOutFile(model, 'ac'));
    
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
 
  % Stamp filename
  if (~isfield(model.ac,'fn'))
      model.ac.fn = de_GetOutFile(model, 'ac');
  end;
  
  % Report total time
  trainTime = 0;
  if (model.ac.cached == 0), trainTime = trainTime + model.ac.trainTime; end;
  if (isfield(model, 'p') && model.p.cached == 0),  trainTime = trainTime + model.p.trainTime;  end;
  
  fprintf(' | t: %5.1fs (%5.1fs', trainTime, model.ac.trainTime);
  if (isfield(model, 'p')), fprintf('+ %5.1fs', model.p.trainTime); end;
  fprintf(')');
  