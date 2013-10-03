function [val, opts, inopts] = guru_popopt(opts, optname, def)
  hasval = exist('def','var');

  if (hasval),       [val, inopts, idx] = guru_getopt(opts, optname, def);
  else,              [val, inopts, idx] = guru_getopt(opts, optname); end;

  if (inopts)
      if (hasval), opts = opts([1:idx-1 idx+2:end]);
      else,        opts = opts([1:idx-1 idx+1:end]); end;
  end;

      