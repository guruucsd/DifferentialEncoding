function c = guru_contains(M,v)
% function c = guru_contains(M,v)
%   Tells whether a matrix contains a member or not.
%   Returns a boolean value
%
%   M: matrix
%   v: values (cell)

  if (~iscell(v))
    error('v must be a cell matrix');
  elseif (isempty(v))
    c = 0;
    return;
  end;

  % Look inside the cell array;
  %  any non-strings will fail.  So,
  %  convert non-strings to strings
  %  and note the index, so we can be
  %  sure to invalidate any accidental match
  %  at such a position at the end.
  str = zeros(size(v));
  for i=1:prod(size(v))
    str(i) = ischar(v{i});
    if (~str(i))
      v{i} = '';
    end;
  end;

  % Find members, and blank out accidental matches
  d = ismember(v,M).*str;

  % Summarize to output
  c = ~isempty(find(d));

