function [model,o_p] = guru_nnTrainAC(model,X,Y)
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
   if (~isfield(model, 'trainMode')), model.trainMode = 'batch'; end;

  startTime = toc;

  switch (model.trainMode)
      case 'batch' 
        if (nargout<2), [model]     = guru_nnTrainAC_batch(model,X,Y);
        else,           [model,o_p] = guru_nnTrainAC_batch(model,X,Y); end;
        
      case 'online'
        if (nargout<2), [model]     = guru_nnTrainAC_online(model,X,Y);
        else,           [model,o_p] = guru_nnTrainAC_online(model,X,Y); end;
    
      case 'resilient'
        if (nargout<2), [model]     = guru_nnTrainAC_resilient(model,X,Y);
        else,           [model,o_p] = guru_nnTrainAC_resilient(model,X,Y); end;
        
      otherwise
        error('Unknown training type: %s', model.trainMode);
  end;
  
  model.trainTime     = toc - startTime;
  model.err           = model.err(1:model.Iterations,:);
  model.avgErr        = mean(model.err(end,:),2)/size(Y,1);
  model.trainingError = sum(model.err(end,:));
  
%%%%%%%%%%%%%%%%%%%
function [model,o_p] = guru_nnTrainAC_batch(model,X,Y)
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
    model.Error = model.AvgError*prod(size(Y));
  end;
 
  model.Eta = model.EtaInit;
  lastErr   = NaN;
  currErr   = NaN;
  
  for ip = 1:model.MaxIterations

    % batch
    ep = 1:size(X,2);
      
    if (exist('o_p', 'var'))
      [model, currErr, lastErr, o_p(ip,:,ep)] = guru_nnTrainAC_inner(X, Y, model, errorType, ep, ip, currErr);
    else
      [model, currErr, lastErr              ] = guru_nnTrainAC_inner(X, Y, model, errorType, ep, ip, currErr);
    end;

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
      break;
    end;
  end;
  
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;


%%%%%%%%%%%%%%%%%%%
function [model,o_p] = guru_nnTrainAC_online(model,X,Y)
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
    model.Error = model.AvgError*size(Y,1);
  end;
 
  model.Eta = model.EtaInit;
  lastErr   = NaN;
  currErr   = NaN;
  
  for ip = 1:model.MaxIterations

    if (~exist('indivCurrErr','var'))
      indivCurrErr = nan(1,size(X,2));
      indivLastErr = nan(1,size(X,2));
    end;
      
    % random sequence
    gg = randperm(size(X,2));

    for ep =1:size(X,2)
      if (exist('o_p', 'var'))
        [model,indivCurrErr(ep), indivLastErr(ep),o_p(ip,:,ep)] = guru_nnTrainAC_inner(X(:,gg(ep)), Y(:,gg(ep)), model, errorType, ep, ip, indivCurrErr(ep));
      else
        [model,indivCurrErr(ep), indivLastErr(ep)] = guru_nnTrainAC_inner(X(:,gg(ep)), Y(:,gg(ep)), model, errorType, ep, ip, indivCurrErr(ep));
      end;
    end;
    currErr = sum(indivCurrErr);
    lastErr = sum(indivLastErr);

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
      break;
    end;
  end;
  
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;


%%%%%%%%%%%%%%%%%%%%
function [model, currErr, lastErr,o_p] = guru_nnTrainAC_inner(X, Y, model, errorType, ep, ip, currErr)
    
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
  

%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function [model,o_p] = guru_nnTrainAC_resilient(model,X,Y)
% Train with basic backprop, in batch mode
  error('resilient backprop NYI');
  
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
    model.Error = model.AvgError*size(Y,1);
  end;
 
  model.Eta = model.EtaInit.*model.Conn;
  lastErr   = NaN;
  currErr   = NaN;
  lastGrad  = zeros(size(model.Conn));
  
  for ip = 1:model.MaxIterations

    if (~exist('indivCurrErr','var'))
      indivCurrErr = nan(1,size(X,2));
      indivLastErr = nan(1,size(X,2));
    end;
      
    % Determine model error
    if (nargout>1)
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
    
    % Had a problem; probably moving too fast.
    if (any(isnan(model.err(ip,:))))
      keyboard
      return; 
    end;
    
    % Adjust the weights
    if (any(isnan(grad(:)))), error('nan?'); end;
    model.Weights=model.Weights-model.Eta.*model.Conn.*sign(grad);
    if (any(isnan(model.Weights(:)))), error('nan?'); end;

    % We're getting better, speed things up
    samesign = (grad.*lastGrad)>0;
    model.Eta=model.Eta + ((model.Acc-1).*samesign);
    model.Eta=model.Eta.*(1 - ((model.Dec-1).*samesign));

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
      break;
    end;
  end;
  
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;

