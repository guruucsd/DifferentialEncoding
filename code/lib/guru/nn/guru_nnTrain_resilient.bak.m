function [model,o_p] = guru_nnTrain_resilient(model,X,Y)
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
 
  model.Eta = model.EtaInit.*model.Conn;
  lastErr   = NaN;
  currErr   = NaN;
  lastGrad  = zeros(size(model.Conn));
  
  
  for ip = 1:model.MaxIterations

    % Determine model error
    if (nargout>1)
        [model.err(ip,:),grad,o_p(ip,:,:)]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType, model.Pow );
    else
        [model.err(ip,:),grad]    =emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType, model.Pow );
    end;
    
    % Change error only if there are no NaN
    if (any(isnan(model.err(ip,:))))
        lastErr = currErr;
    else
        lastErr = currErr;
        currErr = sum(model.err(ip,:));
    end;
    
    % Had a problem; probably moving too fast.
    if (any(isnan(model.err(ip,:))))
      keyboard
      return; 
    end;
    
    % Adjust the weights
    if (any(isnan(grad(:)))), error('nan?'); end;
    model.Weights=model.Weights-model.Eta.*model.Conn.*sign(grad);
    if (isfield(model, 'lambda') && currErr < lastErr)
        %keyboard
        model.Weights = model.Weights * (1-model.lambda);
    end;
    if (any(isnan(model.Weights(:)))), error('nan?'); end;

    % We're getting better, speed things up
    samesign = (grad.*lastGrad)>0;
    model.Eta=model.Eta + ((model.Acc)*currErr.*samesign);
    model.Eta=model.Eta.*(1 - ((model.Dec).*(~samesign)));
lastGrad = grad;

    % Finished training    
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');
        
        
    elseif (currErr <= model.Error)
      if (ismember(3, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
      end;
      break;
      
    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      if (ismember(2, model.debug))
        fprintf('Error didn''t change on iteration %d; done training early.\n',ip);
      end;
      keyboard
      break;
    end;
  end;

  model = rmfield(model,'Eta');
  
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;

