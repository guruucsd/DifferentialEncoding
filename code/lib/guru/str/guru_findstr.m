function is = guru_findstr(str, tomatch, startIdx)
%
%  Just like findstr, BUT
%    - ONLY returns the FIRST MATCH
%    - works on cell arrays
%
%  So, multiple matches => multiple input strings, one match per input string.
%
  if (~exist('startIdx','var'))
    startIdx = 1;
  end;
  
  if (~iscell(str))
    is = findstr(str(startIdx:end), tomatch);
    if (isempty(is))
      is = -1;
    else
      is = is(1);
    end;
    
  else
    is = zeros(size(str));
    for i=1:prod(size(is))
      is(i) = guru_findstr(str{i}, tomatch, startIdx);
    end;
  end;
  
