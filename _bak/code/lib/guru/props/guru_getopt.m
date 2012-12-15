function [val, inopts, idx] = guru_getopt(opts, optname, def)

  hasdefval = exist('def',    'var');
  
  %[inopts, idx] = ismember(opts, optname);
  inopts = 0; idx=0;
  for i=1:length(opts)
      if (ischar(opts{i}) && strcmp(opts{i}, optname))
          inopts = 1;
          idx    = i;
          break;
      end;
  end;
  
  

  
  if (~inopts && hasdefval)
    val = def;
  elseif (~inopts && ~hasdefval)
    error('Option %s is required, but not specified.', optname);
  elseif (length(opts)>idx)
    val = opts{idx+1};
  else
    error('Option %s must be followed by a value.', optname);
  end;
