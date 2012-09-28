function [oact,err,huact] = guru_nnExec(model,X,Y)
%  Run a model
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
%  o    : calculated output at LAST step.

  if (~isfield(model,'Conn')), model.Conn = double(model.Weights~=0); end;
  
  errorType   = 4-mod(model.errorType,2); % get out all data
  
  % Determine model error
  [err,grad,o]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, errorType );

  nOutput = size(Y,1);
  oact = o((end-nOutput+1):end,:);
  
  if (nargout>2)
    nInput = size(X,1);
    huact = o((nInput+1):(end-nOutput),:);
  end;