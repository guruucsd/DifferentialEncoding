function [C, mu] = de_connector1D(nInput, nHidden, nConn, sigma)
%
  [C,mu] = feval(sprintf('de_connector1D_%d', nInput), nHidden, nConn, sigma);