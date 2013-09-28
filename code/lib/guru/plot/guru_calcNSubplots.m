function [nrows,ncols] = guru_calcNSubplots(nPlots, w2hratio)
%
% w2hratio: desired width2height ratio.  If not specified, taken from screen dimensions
%
%

  if (~exist('w2hratio','var'))
    ss = get( 0, 'ScreenSize' );
    w2hratio = ss(3)/ss(4);
  end;
  
  nrows = ceil(nPlots^(1/w2hratio));
  ncols = ceil(nPlots / nrows);