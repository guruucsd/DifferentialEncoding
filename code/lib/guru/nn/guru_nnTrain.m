function [model,o_p] = guru_nnTrain(model,X,Y)
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

  if (~isfield(model, 'TrainMode')), model.TrainMode = 'batch'; end;
  try, startTime = toc; catch err, tic; startTime = toc; end;
  
  nUnits = size(model.Weights,1); nOutput = size(Y,1); nInput = size(X,1); nHidden = nUnits-nOutput-nInput;
  if (isfield(model, 'linout') && model.linout && length(model.XferFn) ~= (nHidden+nOutput))
    old_xferfn = model.XferFn;
    model.XferFn = [model.XferFn*ones(1,nHidden) ones(1,nOutput)]; %linear hidden->output
  elseif (length(model.XferFn)==2)
    old_xferfn = model.XferFn;
    model.XferFn = [model.XferFn(1)*ones(1,nHidden) model.XferFn(2)*ones(1,nOutput)];
  end;

  switch (model.TrainMode)
      case 'batch' 
        if (nargout<2), [model]     = guru_nnTrain_batch(model,X,Y);
        else,           [model,o_p] = guru_nnTrain_batch(model,X,Y); end;
        
      case 'online'
        if (nargout<2), [model]     = guru_nnTrain_online(model,X,Y);
        else,           [model,o_p] = guru_nnTrain_online(model,X,Y); end;
    
      case 'resilient'
        if (nargout<2), [model]     = guru_nnTrain_resilient(model,X,Y);
        else,           [model,o_p] = guru_nnTrain_resilient(model,X,Y); end;

      case 'bptt'
        if (nargout<2), [model]     = guru_nnTrain_bptt_batch(model,X,Y);
        else,           [model,o_p] = guru_nnTrain_bptt_batch(model,X,Y); end;

      otherwise
        error('Unknown training type: %s', model.trainMode);
  end;
  
  
  model.err                  = model.err(1:model.Iterations(end),:);

  if (~isfield(model, 'trainTime')),     model.trainTime     = zeros(0,1); end;
  if (~isfield(model, 'avgErr')),        model.avgErr        = zeros(0,1); end;
  if (~isfield(model, 'trainingError')), model.trainingError = zeros(0,1); end;

  model.trainTime(end+1)     = toc - startTime;
  model.avgErr(end+1)        = mean(model.err(end,:),2)/size(Y,1);
  model.trainingError(end+1) = sum(model.err(end,:));

    % Undo expansion of XferFn, for caching purposes
  if (exist('old_xferfn','var'))
      model.XferFn = old_xferfn;
      clear('old_xferfn')
  end;


