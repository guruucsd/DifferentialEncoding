function [oact, err, huact] = guru_nnExec(model,X,Y)
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

  % Calc
  nUnits = size(model.Weights,1);
  nIn = size(X,1)-1;
  nOut = size(Y,1);
  nHid = nUnits-nIn-nOut-1; % remove input, output, and

  % Set up transfer function for each unit
  if (length(model.XferFn)==2)
    model.XferFn = [model.XferFn(1)*ones(1,nHid) model.XferFn(2)*ones(1,nOut)];
  end;

  % Special case for dropout
  %   reduce the value of the hidden->output weights by dropout %
  if (isfield(model, 'dropout'))
    model.Weights(nIn+1+nHid+[1:nOut], nIn+1+[1:nHid]) = (1-model.dropout)*model.Weights(nIn+1+nHid+[1:nOut], nIn+1+[1:nHid]);
  end;

  % Execute the model and determine the errorType
  if ~isfield(model, 'ts')
    [err,~,o]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType );

  % Multiple loops
  else
    if isfield(model, 'debug') && ismember(11,model.debug) && model.ts > 1
      fprintf('Running %d re-entrant loops of model\n', model.ts);
    end;

    oy = X(1:nIn,:);
    for tsi=1:model.ts
      %if model.useBias
        [err,~,o]=emo_backprop([oy;X(end,:)], Y, model.Weights, model.Conn, model.XferFn, model.errorType );
      %else
      %  [err,grad,oz]=emo_backprop(o, Y, model.Weights, model.Conn, model.XferFn, model.errorType );
      %end
      oy = o(nIn+1+nHid+[1:nOut],:);
    end;
  end;

  oact = o(nIn+1+nHid+[1:nOut], :);

  if (nargout>2)
    huact = o(nIn+1+[1:nHid], :);
  end;
