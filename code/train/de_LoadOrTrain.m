function model = de_LoadOrTrain(model)
%
% Figures out whether ac or p needs to be trained.
%   If so, trains 'em up
%   If not, loads results metadata from disk
% Output model is the 'clean' version without 'heavy' props
%

  % Load autoencoder, if exists
  if (   exist(de_getOutFile(model, 'ac'),         'file') ...
      && exist(de_getOutFile(model, 'ac.weights'), 'file') ...
      && exist(de_getOutFile(model, 'ac.err'),     'file'))
      
    model.ac        = guru_loadVars(de_getOutFile(model, 'ac'), 'ac');
    model.ac.cached = 1;
  else
    model.ac.cached = 0;
  end;
  
  % Load perceptron, if exists
  if (   exist(de_getOutFile(model, 'p'),          'file') ...
      && exist(de_getOutFile(model, 'p.weights'),  'file') ...
      && exist(de_getOutFile(model, 'p.output'),   'file'))
    model.p        = guru_loadVars(de_getOutFile(model, 'p'),  'p');
    model.p.cached = 1;
  else
    model.p.cached = 0;
  end;
    
  switch (model.deType)
    case 'de',         model = de_DE   (model);
    case 'de-mtl',     model = de_DEMTL(model);
    case 'de-compact', model = model;
    otherwise, error('Unknown DE type: %s', model.deType);
  end;
 
  % Report total time
  trainTime = 0;
  if (model.ac.cached == 0), trainTime = trainTime + model.ac.trainTime; end;
  if (model.p.cached == 0),  trainTime = trainTime + model.p.trainTime;  end;
  
  fprintf(' | t: %5.1fs (%5.1fs + %5.1fs)', trainTime, model.ac.trainTime, model.p.trainTime);