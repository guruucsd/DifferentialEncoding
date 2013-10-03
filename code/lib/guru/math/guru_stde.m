function stde = guru_stde(m,dim)
%
%
  if (~exist('dim','var')), dim=1; end;
  
  stde = std(m,dim) / sqrt(size(m,dim));