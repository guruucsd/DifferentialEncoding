function is = guru_findstr(str, tomatch, startIdx,style)
%is = guru_findstr(str, tomatch, startIdx,style)
%  Just like findstr, BUT
%    - ONLY returns the FIRST MATCH
%    - works on cell arrays
%
%  So, multiple matches => multiple input strings, one match per input string.
%
% str: string (or cell array)
% tomatch: substring to match
% startIdx: index inside string to start searching
%     (str if ischar, or each string element of the cell array)
% style: all or first or last (only applies when str is a cell array)

  if (~exist('startIdx','var')), startIdx = 1; end;
  if (~exist('style', 'var')), style='all'; end;

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

  switch style
    case 'all', ; % do nothing
    case 'first', is = is(1);
    case 'last', is=is(end);
    otherwise, error('Unknown style parameter: %s', style);
  end;
  
