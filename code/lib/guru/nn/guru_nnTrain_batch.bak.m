function [model,o_p] = guru_nnTrain_batch(model,X,Y)
% Train with basic backprop, in batch mode

  nInputs   = size(Y,1);
  nDatapts  = size(Y,2);
  nUnits    = size(model.Weights,1);
  nOutputs  = nInputs;
  nHidden   = nUnits - nInputs - nOutputs;
  
  errorType = 4-mod(model.errorType,2); % get out all datak
  model.err = zeros([model.MaxIterations nDatapts]);

  % Only do if necessary, for memory reasons  
  if (nargout>1)
      o_p       = zeros([model.MaxIterations nUnits nDatapts]);
  end;

  if (~isfield(model,'Error'))
    model.Error = model.AvgError*numel(Y);
  end;
 
  model.Eta = model.EtaInit;
  lastErr   = NaN;
  currErr   = NaN;
  
  for ip = 1:model.MaxIterations

    % batch
    ep = 1:size(X,2);
      
    if (exist('o_p', 'var'))
      [model, currErr, lastErr, o_p(ip,:,ep)] = guru_nnTrain_inner(X, Y, model, errorType, ep, ip, currErr);
    else
      [model, currErr, lastErr              ] = guru_nnTrain_inner(X, Y, model, errorType, ep, ip, currErr);
    end;

    % Finished training    
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');
        
        
    elseif (currErr <= model.Error)
      if (ismember(3, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
          keyboard
      end;
      break;
      
    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      if (ismember(2, model.debug))
        fprintf('Error didn''t change on iteration %d; done training early.\n',ip);
      end;
      break;
    end;
  end;
  
  
  model = rmfield(model, 'Eta');
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;
