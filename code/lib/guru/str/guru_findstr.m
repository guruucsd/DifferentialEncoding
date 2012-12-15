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
    tmp = findstr(str(startIdx:end), tomatch);
    if (isempty(tmp))
      is = 0;
    else
      is = tmp(1);
    end;
    
  else
    is = zeros(size(str));
    for i=1:numel(is)
      if (~ischar(str{i}))
          is(i) = 0;
      else
        tmp = findstr(str{i}(startIdx:end), tomatch);
        if (isempty(tmp))
          is(i) = 0;
        else
          is(i) = tmp(1);
        end;
      end;
    end;
  end;
  
