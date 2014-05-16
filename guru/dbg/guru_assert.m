function guru_assert( b, s )
%
%

  if (~b)
    if (exist('s','var'))
      error(s);
    else
      error('Assertion failure.');
    end;
  end;