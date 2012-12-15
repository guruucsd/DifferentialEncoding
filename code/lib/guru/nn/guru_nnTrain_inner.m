function [model, currErr, lastErr,o_p] = guru_nnTrain_inner(X, Y, model, errorType, ep, ip, currErr)
    
    % Determine model error
    if (nargout==4)
        [model.err(ip,ep),grad,o_p]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType );
    else
        [model.err(ip,ep),grad]    =emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType );
    end;
    if (~any(isnan(model.err(ip,ep))))
        lastErr = currErr;
        currErr = sum(model.err(ip,ep));
    else
        lastErr = currErr;
    end;
    
    % Figure out new learning rate


    % Had a problem; probably moving too fast.
    if (any(isnan(model.err(ip,ep))))
      model.Eta = model.Eta/model.Dec;
      return; 
      
    % We're getting better, speed things up
    elseif( currErr < lastErr )
      model.Eta=model.Eta*model.Acc;
      
    % We're getting worse, slow things down
    elseif( currErr > lastErr && (ip/model.MaxIterations > 0.05)) % don't start decelerating until after at least 5% of iterations
      model.Eta=model.Eta/model.Dec;
    end;
    
    % Adjust the weights
    %if (any(isnan(grad(:)))), error('nan?'); end;
    model.Weights=model.Weights-model.Eta.*model.Conn.*grad;
    
    % Regularization
    if (isfield(model, 'lambda') && currErr < lastErr)
        %keyboard
        model.Weights = model.Weights * (1-model.lambda);
    end;
    %if (any(isnan(model.Weights(:)))), error('nan?'); end;

    %model.Weights = max(min(model.Weights, 100), -100);
    
    
  % Don't train on weights for inputs that have zero variance.
  %s = std(X,[],2);
  %if (length(find(s==0)>0) && ismember(1, model.debug)), fprintf('  [%d/%d] ', length(find(s)), size(s,1)); end; 
  %model.Weights( (nInputs+(1:nHidden)), find(s==0) ) = 0; % input->hidden; set weight to 
  %model.Weights( (nInputs+nHidden+(find(s==0))), (nInputs+(1:nHidden)) ) = 0; % hidden->output
  
  %if (~isfield(model,'Error')), model.Error = model.AvgError*prod(length(find(s))*size(Y,2)); end;
  

    
  % Don't train on weights for inputs that have zero variance.
  %s = std(X,[],2);
  %if (length(find(s==0)>0) && ismember(1, model.debug)), fprintf('  [%d/%d] ', length(find(s)), size(s,1)); end; 
  %model.Weights( (nInputs+(1:nHidden)), find(s==0) ) = 0; % input->hidden; set weight to 
  %model.Weights( (nInputs+nHidden+(find(s==0))), (nInputs+(1:nHidden)) ) = 0; % hidden->output
  
  %if (~isfield(model,'Error')), model.Error = model.AvgError*prod(length(find(s))*size(Y,2)); end;
  