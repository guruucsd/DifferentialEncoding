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
    if (model.ac.cached==0)
      weights = model.ac.Weights;
      save( de_GetOutFile(model, 'ac.weights'), 'weights');
      clear('weights');
    end;
    
    % clean
    model.ac = rmfield(model.ac, 'Weights');

      
    % output
    if (isfield(model.ac,'err'))
      if (model.ac.cached == 0)
        err = model.ac.err;
        save( de_GetOutFile(model, 'ac.err'), 'err');
        clear('err');
      end;
      
      % clean
      model.ac = rmfield(model.ac, 'err');
    
      % metadata
      if (model.ac.cached == 0)
        ac = model.ac;
        save( de_GetOutFile(model, 'ac'), 'ac');
        clear('ac');
      end;
    end;
  end;  

  
  %% p
  if (isfield(model, 'p'))
      % weights  
      if (isfield(model.p, 'Weights'))
        if (model.p.cached == 0)
          weights = model.p.Weights;
          save( de_GetOutFile(model, 'p.weights'), 'weights');
          clear('weights');
        end;

        % clean
        model.p = rmfield(model.p, 'Weights');

        % output
        if (isfield(model.p, 'output'))
          if (model.p.cached == 0)
            output = model.p.output;
            save( de_GetOutFile(model, 'p.output'), 'output');
            clear('output');
          end;

          % clean
          model.p = rmfield(model.p, 'output');

          % metadata
          if (model.p.cached == 0)
            p = model.p;
            save( de_GetOutFile(model, 'p'), 'p');
            clear('p');
          end;
        end;
      end;
  end;
