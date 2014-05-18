function [model,o_p] = guru_nnTrainAC(model,X)
%function [model,o_p] = guru_trainNN(model,X)
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

  if (model.useBias), Y = X(1:end-1,:);
  else,                  Y = X;
  end;

  if (nargout<2), [model]     = guru_nnTrain(model,X,Y);
  else,           [model,o_p] = guru_nnTrain(model,X,Y);
  end;
