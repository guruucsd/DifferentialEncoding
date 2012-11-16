function [train,test] = create_dataset(ws, model, ii)
%
%


  if exist('ii','var') && ws.kernels(ii) > 1
    opts = {ws.dataset_train.opts{:}, 'lowpass', 1.25};
  else
    opts = ws.dataset_train.opts;
  end;
  opts

  % Use the same whitening transform for all datasets
  if isfield(ws,'fullfidel') && isfield(ws.fullfidel,'axes')
    opt{find(guru_findstr(ws.fullfidel.opt,'dnw'))+1} = ws.fullfidel.axes;
  end;

	switch(ws.dataset_train.name)
		case {'c' 'cafe'},   [~, train, test] = de_MakeDataset('young_bion_1981',     'orig',    '', opts);
		case {'n' 'natimg'}, [~, train, test] = de_MakeDataset('vanhateren',          'orig',    '', opts);
		case {'s' 'sf'},     [~, train, test] = de_MakeDataset('sf',                  'vertonly','', opts);
		case {'r' 'ch'},     [~, train, test] = de_MakeDataset('christman_etal_1991', 'all_freq','', opts);
		case {'u' 'uber'},   [~, train, test] = de_MakeDataset('uber',                'all',     '', opts);
		otherwise,      error('dataset %s NYI', dataset_train{si});
	end;

  %%%%%%%%%%%%%%%%%
  % Create & load stimulus set into some expected schema
  %%%%%%%%%%%%%%%%%

  if exist('model','var')
    if (isfield(ws,'fullfidel') && isfield(ws.fullfidel,'axes')) % standard to which to normalize data
      train.axes = ws.fullfidel.axes;
      test.axes = train.axes;
    end;
    train = de_NormalizeDataset(train, struct('ac',model));
    test  = de_NormalizeDataset(test, struct('ac',model'));
  end;

