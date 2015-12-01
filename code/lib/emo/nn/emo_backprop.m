function [Err, Grad, Out] = emo_backprop( X, T, W, Con, Trn, Ern, Pow )
%[Err, Grad, Out] = backprop( X, T, W, Con, Trn, Ern )
%
%Compute error and gradient of feedforward network via backpropagation
%
% X: inputs; each column of the matrix X is an input vector
% T: target outputs; each column of T is a desired output vector
%     correspoding to the input vector given by the same column of X
% W: synaptic weights; W(j,i) is the weight from unit i to unit j;
%     non-existing weights are ignored
% Con: network topology; Con(j,i) = 1 iff weight from i to j exists
% Trn: type of transfer function for each non-input unit:
%       1- linear; 2- soft-threshold; 3- sigmoid; 4- tanh
%       if Trn is scalar, the same type is used for all units
% Ern: (optional) error function to use
%       1- linear; 2-sum-squared error (default)
% The total number of units is (W,1).
% The first size(X,1) "units" are inputs with identity transfer functions.
% When Trn is a vector it should not include the input units;
%  thus the length of Trn should be either n_layers or size(W,1)-size(X,1).
%
% Err: squared error summed over all data points
% Grad: gradient of Err with respect to W; Grad is a matrix with same
%        size as W and Con; non-existing elements are set to 0
% Out: the outputs of the network for the current inputs and weights
%
%NOTE: Simple gradient descent can be implemented as W = W - rate*Grad.
%      When using a more efficient second-order method one should
%      remove the non-existing weights and turn the weight matrix W
%      into a vector:  w_vec = W(Con==1).

% Copyright (C) Emanuel Todorov, 2004-2006

  if (~exist('Ern','var')), Ern = 2; end;
  if (~exist('Pow','var')), Pow = 1; end;

  % compute sizes
  nTotal    = size(W,1);
  nInput    = size(X,1);
  nOutput   = size(T,1);
  nHidden   = nTotal - nInput - nOutput;
  nData     = size(X,2);

  idxInput = 1:nInput;
  idxHidden = (nInput+1):(nTotal-nOutput);
  idxOutput = (nTotal-nOutput+1 : nTotal);

  % Check for multilevel.  % >1 because every unit connects with the bias.
  idxHiddenByLayer = {};
  idxCurConn = nInput + find(sum(Con(idxHidden, idxInput), 2) > 1);
  while any(idxCurConn)
      idxHiddenByLayer{end+1} = idxCurConn;
      idxCurConn = nInput + find(sum(Con(idxHidden, idxCurConn), 2) > 1);
  end;

  % Set up transfer functions
  if numel(Trn) ~= nTotal-nInput
      if length(Trn) == 1
          Trn = Trn*ones(nTotal-nInput, 1);
      elseif length(Trn) == length(idxHiddenByLayer) + 1
          tmp = ones(nTotal-nInput, 1);
          for li=1:length(idxHiddenByLayer)
              tmp(idxHiddenByLayer{li} - nInput) = Trn(li);
          end;
          tmp(idxOutput - nInput) = Trn(end);
          Trn = tmp;
      end;
  end;

  % remove nonexistent weights
  W = W .* Con;

  % allocate variables
  Out = zeros(nTotal,nData);    % outputs
  d   = zeros(nTotal,nData);      % deltas
  z   = zeros(nTotal,nData);      % internal activations
  h1  = zeros(nTotal,nData);      % h'(z)

  % initialize forward pass
  Out(1:nInput,:) = X;

  % run forward pass
  for li=1:length(idxHiddenByLayer)
      idxCur = idxHiddenByLayer{li};
      z(idxCur, :) = W(idxCur, :) * Out;
      [Out(idxCur,:), h1(idxCur,:)] = emo_trnsfr( Trn(idxCur(1)-nInput), z(idxCur,:) );
  end;

  z(idxOutput,:) = W(idxOutput,:) * Out;
  [Out(idxOutput,:), h1(idxOutput,:)] = emo_trnsfr( Trn(idxOutput(1)-nInput), z(idxOutput,:) );


  % Compute error and error derivative
  %d_a = T - Out(idxOutput,:);   % compute residuals (desired minus actual outputs)
  [Err, Errp] = emo_nnError(Ern, Out(idxOutput, :), T);

  % initialize backward pass
  d(idxOutput,:) = - (Errp.^Pow) .* h1(idxOutput,:); % use "pow" here, so that ERROR reports are on regular error; POW only affects the gradient

  % run backward pass over hidden units, one-by-one
  for li=length(idxHiddenByLayer):-1:1
      idxCur = idxHiddenByLayer{li};
      d(idxCur,:) = h1(idxCur,:) .* (W(:,idxCur)'*d);
  end;

  % Run backwards pass from Hidden->Input
  idxCur = 1:nInput;
  d(idxCur,:) = h1(idxCur,:) .* (W(:,idxCur)'*d);

  % Output error (across all output nodes) and gradient
  Err  = sum(Err, 1); %  Err = sum(sum(d_a.^2))/ 2;
  Grad = (d*Out') .* Con;


