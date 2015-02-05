function [o, h1] = emo_trnsfr( Trn, z )
%function [o, h1] = emo_trnsfr( Trn, z )
%
% compute specified transfer function and its derivative
%
% o == transfer function, at z
% h1 = derivative of transfer function, at specified points (z)
%
% Copyright (C) Emanuel Todorov, 2004-2006

  switch Trn,
  case 1,                 % linear
      o = z;
      if nargout>1, h1 = ones(size(z)); end;
      
  case 2,                 % soft-threshold
      o = log(exp(z)+1); 
      if nargout>1, h1 = exp(z)./(1+exp(z)); end;
      
  case 3,                 % sigmoid
      o = 1./(1+exp(-z));
      if nargout>1, h1 = o - o.^2; end;
      
  case 4,                 % tanh
      o = (exp(z)-exp(-z)) ./ (exp(z)+exp(-z));
      if nargout>1, h1 = 1 - o.^2; end;

  case 5,                 % 0-mean sigmoid
      o = 1./(1+exp(-z)) - 0.5;
      if nargout>1, h1 = o - o.^2; end;
    
  case 6,                 % BIG tanh: 1.71*tanh(2*x/3)
      o  = 1.7159*(2 ./ (1 + exp(-2 * 2*z/3)) - 1);
      if nargout>1, h1 = 1.7159*2/3*(1 - (o/1.7159).^2); end;

  case 7,
      exps  = exp(z);
      sexps = repmat(sum(exps,1), [size(z,1),1]);
      o     = exps./sexps;
      if nargout>1, h1    = (sexps+1)./(sexps.^2); end;

  otherwise,
      error('Unknown transfer function type');
  end
