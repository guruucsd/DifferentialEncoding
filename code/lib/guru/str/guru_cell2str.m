function [out] = guru_cell2str(cel, div, fmt)
%
% if div is present, then concatenate cell elements into a string
% if not, then return a cell matrix of strings

  if ~exist('div','var'), div=' '; end;
  out = guru_csprintf([], cel);
  if (exist('div','var'))
      if (isempty(cel))
          out = '{}';
      else
          out = sprintf('{%s}', sprintf([div '%s'], out{:})); 
          out = out([1 (2+length(div)):end]);    
      end;
  
  end;
