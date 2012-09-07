function err = de_calcPErr(o_p, T, errorType)
% 
% Takes some matrix of outputs over a # of iterations
%   and a matrix of expected outputs.
% Computes the error over all output nodes
%   for each iteration

  nIters = size(o_p,1);
  vecT  = reshape(T, [1 prod(size(T))]);
  Y     = repmat(vecT, [nIters 1]);
  
  err = emo_nnError(o_p - Y, errorType);
  err = reshape(err, [nIters size(T)]);
  err = reshape(nan_mean(err, 2), [nIters size(T,2)]);