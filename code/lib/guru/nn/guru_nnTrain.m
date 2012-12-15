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
  startTime = toc;
  
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
        
      otherwise
        error('Unknown training type: %s', model.trainMode);
  end;
  
  model.trainTime     = toc - startTime;
  model.err           = model.err(1:model.Iterations,:);
  model.avgErr        = mean(model.err(end,:),2)/size(Y,1);
  model.trainingError = sum(model.err(end,:));
  
