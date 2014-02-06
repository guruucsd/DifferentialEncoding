function [val, opts, inopts] = guru_popopt(opts, optname, def)
% def = default value

  hasdefval = exist('def','var');

  if (hasdefval), [val, inopts, idx] = guru_getopt(opts, optname, def);
  else,           [val, inopts, idx] = guru_getopt(opts, optname); end;

  if (inopts)
      opts = opts([1:idx-1 idx+2:end]);
  end;

      