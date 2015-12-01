function [val, inopts, idx] = guru_getopt(opts, optname, def)

  hasdefval = exist('def',    'var');

  %[inopts, idx] = ismember(opts, optname);
  inopts = 0; idx=0;
  for ii=length(opts):-1:1
      if (ischar(opts{ii}) && strcmp(opts{ii}, optname))
          inopts = 1;
          idx    = ii;
          break;  % don't stop--get the final value!
      end;
  end;


  if (~inopts)
      if (hasdefval)
        val = def;
      else
        error('Option %s is required, but not specified.', optname);
      end;

  else
    if (idx<length(opts))
      val = opts{idx+1};
    elseif (hasdefval),
      val = def;
    else
      error('Option %s is required, but not specified.', optname);
    end;
  end;