function model = de_CompressAndSave(model)
% This function:
%  * removes large, redundant information (ac.Conns, p.Conns are both
%      implicitly found in ac.Weights, p.Weights
%  * saves large matrices to disk (ac.Weights, p.Weights, ac.err, p.output
%  * removes those properties from the models (we'll have to load them back up any time we need them)
%
% Inputs:
%   model (may or may not have these large / redundant properties, or a bit suggesting that the data has already been cached)
%
% Output:
%   model (cleaned version)
%   (files to disk if necessary)
%

  % Remove DUPLICATE bits
  model = de_CompressModels(model);

  % make output directories
  d = de_GetOutPath(model, 'ac');  if (~exist(d, 'dir')), mkdir(d);  end;
  d = de_GetOutPath(model, 'p');   if (~exist(d, 'dir')), mkdir(d);  end;
  clear('d');

  %% ac
  % weights
  if (isfield(model.ac, 'Weights'))
    fwts = de_GetOutFile(model, 'ac.weights');
    if (~exist(fwts,'file'))
      weights = model.ac.Weights;
      save( fwts, 'weights');
      clear('weights');
    end;
    clear('fwts');
    model.ac = rmfield(model.ac, 'Weights');
  end;


    % output
  if (isfield(model.ac,'err'))
    ferr = de_GetOutFile(model, 'ac.err');
    if (~exist(ferr,'file'))
      err    = model.ac.err;
      save( ferr, 'err');
      clear('err');
    end;
    clear('ferr');
    model.ac = rmfield(model.ac, 'err');
  end;

  % Hidden units
  if (isfield(model.ac,'hu'))
    fhu = de_GetOutFile(model, 'ac.hu');
    if (~exist(fhu,'file'))
      hu     = model.ac.hu;
      save( fhu, 'hu');
      clear('hu');
    end;
    clear('fhu');
    model.ac = rmfield(model.ac, 'hu');
  end;

    % Output
    if (isfield(model.ac,'output'))
      output = model.ac.output;
      save( de_GetOutFile(model, 'ac.output'), 'output');
      clear('output');
      model.ac = rmfield(model.ac, 'output');
    end;

    % metadata
    ac = model.ac;
    save( de_GetOutFile(model, 'ac'), 'ac');
    clear('ac');
  %end;


  %% p
  if (isfield(model, 'p'))

    % weights
    if (isfield(model.p, 'Weights'))
      fwts = de_GetOutFile(model, 'p.weights');
      if (~exist(fwts,'file'))
        weights = model.p.Weights;
        save( fwts, 'weights');
        clear('weights');
      end;
      clear('fwts');
      model.p = rmfield(model.p, 'Weights');
    end;

    % output
    %if (isfield(model.p, 'output'))
    %    output = model.p.output;
    %    save( de_GetOutFile(model, 'p.output'), 'output');
    %    clear('output');
    %
    %    % clean
    %    model.p = rmfield(model.p, 'output');
    %  end;

      % metadata
    p = model.p;
    save( de_GetOutFile(model, 'p'), 'p');
    clear('p');
  end;
