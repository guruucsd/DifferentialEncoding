function [o, h1] = emo_trnsfr( Trn, z )
%function [o, h1] = emo_trnsfr( Trn, z )
%
% compute specified transfer function and its derivative
%
% Copyright (C) Emanuel Todorov, 2004-2006

  switch Trn,
  case 1,                 % linear
      o = z;
      h1 = ones(size(z));
      
  case 2,                 % soft-threshold
      o = log(exp(z)+1); 
      h1 = exp(z)./(1+exp(z));
      
  case 3,                 % sigmoid
      o = 1./(1+exp(-z));
      h1 = o - o.^2;
      
  case 4,                 % tanh
      o = (exp(z)-exp(-z)) ./ (exp(z)+exp(-z));
      h1 = 1 - o.^2;
      
  case 5,                 % 0-mean sigmoid
      o = 1./(1+exp(-z)) - 0.5;
      h1 = o - o.^2;
    
  case 6,                 % BIG tanh: 1.71*tanh(2*x/3)
      o  = 1.7159*(2 ./ (1 + exp(-2 * 2*z/3)) - 1);
      h1 = 1.7159*2/3*(1 - (o/1.7159).^2);

  case 7,
      exps  = exp(z);
      sexps = repmat(sum(exps,1), [size(z,1),1]);
      o     = exps./sexps;
      h1    = (sexps+1)./(sexps.^2);

  otherwise,
      error('Unknown transfer function type');
  end
