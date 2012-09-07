function [str] = guru_cell2str(cel, fmt)
  if (~exist('fmt','var'))
    fmt = '''%s''';
  end;
  
  if (isempty(cel))
    str = '{}';
  else
    str = sprintf('{%s}', sprintf([' ' fmt], cel{:}));
  end;
