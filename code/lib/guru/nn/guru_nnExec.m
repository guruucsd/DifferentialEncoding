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
  if isfield(model, 'linout'), warning('linout deprecated; use XferFn with multiple values instead.'); end;

  % Set up transfer function for each unit
  nUnits = size(model.Weights,1); nOutput = size(Y,1); nInput = size(X,1); nHidden = nUnits-nOutput-nInput;
  if (isfield(model, 'linout') && model.linout && length(model.XferFn) ~= (nHidden+prod(nOutput)))
    model.XferFn = [model.XferFn*ones(1,nHidden) ones(1,nOutput)]; %linear hidden->output
  elseif (length(model.XferFn)==2)
    model.XferFn = [model.XferFn(1)*ones(1,nHidden) model.XferFn(2)*ones(1,nOutput)];
  end;

  % Special case for dropout
  %   reduce the value of the hidden->output weights by dropout %
  if (isfield(model, 'dropout'))
    model.Weights(nInput+nHidden+[1:nOutput], nInput+[1:nHidden]) = model.dropout*model.Weights(nInput+nHidden+[1:nOutput], nInput+[1:nHidden]);
  end;

  % Execute the model and determine the errorType
  if ~isfield(model, 'ts')
    [err,grad,o]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType );
  else
    o = X(1:end-1,:);
    for tsi=1:model.ts
      if model.useBias
        [err,grad,oz]=emo_backprop([o;X(end,:)], Y, model.Weights, model.Conn, model.XferFn, model.errorType );
      else
        [err,grad,oz]=emo_backprop(o, Y, model.Weights, model.Conn, model.XferFn, model.errorType );
      end
      o = oz(1:(size(X,1)-model.useBias),:);
    end
  end;

  nOutput = size(Y,1);
  oact = o((end-nOutput+1):end,:);
  
  if (nargout>2)
    nInput = size(X,1);
    huact = o((nInput+1):(end-nOutput),:);
  end;
