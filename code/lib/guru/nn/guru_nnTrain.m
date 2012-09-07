function [model,o_p] = guru_trainNN(model,X,Y)
%function [model,o_p] = guru_trainNN(model,X,Y)
%  Train a neural network using backpropogation
%  
%  Input:
%  model : model object (see guru_nn_model for details)
%  X     : input layer values: rows=input values, cols=training examples
%  Y     : output layer (expected) values: rows=output values, cols=training examples
%
%  Output:
%  model  : same as input model, but ending parameters (weights, eta, etc) available
%    .err : matrix of errors: rows=training steps, cols=training examples
%
%  o_p    : calculated output at LAST step.

%  if (~isfield(model,'debug')), model.debug = 0; end;
  startTime = toc;

  if (~isfield(model,'Error')), model.Error = model.AvgError*prod(size(Y)); end;
  
  nUnits   = size(model.Weights,1);
  nOutputs = size(Y,2);
  
  errorType   = 4-mod(model.errorType,2); % get out all datak
  model.err = zeros([model.MaxIterations nOutputs]);
  o_p       = zeros([model.MaxIterations nUnits nOutputs]);
  
  model.Eta = model.EtaInit;
  lastErr   = NaN;
  currErr   = NaN;
  for ip = 1:model.MaxIterations
  
    % Determine model error
    [model.err(ip,:),grad,o_p(ip,:,:)]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType );
    lastErr = currErr;
    currErr = sum(model.err(ip,:));
    
    % Figure out new learning rate


    % Just started, no way to tell
    if (isnan(lastErr))
      ; 
    % We're getting better, speed things up
    elseif( currErr < lastErr )
      model.Eta=model.Eta*model.Acc;
      
    % We're getting worse, slow things down
    elseif( currErr > lastErr && (ip/model.MaxIterations > 0.05)) % don't start decelerating until after at least 5% of iterations
      model.Eta=model.Eta/model.Dec;
    end;
    
    % Adjust the weights
    model.Weights=model.Weights-(model.Eta*grad);

    % Finished training    
    if (currErr <= model.Error)
      break;
      
    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      if (ismember(2, model.debug))
        fprintf('Error didn''t change on iteration %d; done training early.\n',ip);
      end;
      break;
    end;

  end;
     
  % 
  model.Iterations    = ip;
  model.trainTime     = toc - startTime;
  
  % Reduce outputs to actual data.
  o_p                 = o_p(1:model.Iterations,:,:);
  model.err           = model.err(1:model.Iterations,:);
  model.trainingError = sum(model.err(end,:));
  
