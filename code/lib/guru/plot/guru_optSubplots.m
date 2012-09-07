function [nRows,nCols] = guru_optSubplots(nPlots, screenRatio)
%
% x/y=c*(4/3); x*y=nPlots =>x=c*(4/3)*nPlots/x->c=1/(4/3 * nPlots)
%  c = nPlots*(3/4)
%  ceil(c) = x; y=x/(c*(4/3))
 
  if (~exist('screenRatio','var')), screenRatio = 4/3; end;

  nCols = ceil(sqrt(screenRatio*nPlots));
  nRows = ceil(nPlots/nCols);
  
  if (ceil(nPlots/nRows)<nCols)
    nCols = ceil(nPlots/nRows);
  end;