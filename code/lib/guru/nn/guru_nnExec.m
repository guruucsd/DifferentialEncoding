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
  
  nUnits = size(model.Weights,1); nOutput = size(Y,1); nInput = size(X,1); nHidden = nUnits-nOutput-nInput;
  if (isfield(model, 'linout') && model.linout && length(model.XferFn) ~= (nHidden+prod(nOutput)))
    model.XferFn = [model.XferFn*ones(1,nHidden) ones(1,nOutput)]; %linear hidden->output
  elseif (length(model.XferFn)==2)
    model.XferFn = [model.XferFn(1)*ones(1,nHidden) model.XferFn(2)*ones(1,nOutput)];
  end;

  % Determine model error
  [err,grad,o]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType );

  nOutput = size(Y,1);
  oact = o((end-nOutput+1):end,:);
  
  if (nargout>2)
    nInput = size(X,1);
    huact = o((nInput+1):(end-nOutput),:);
  end;
