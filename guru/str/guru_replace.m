function str = guru_replace(str, fstr, rstr)
  idx = guru_findstr(str, fstr);
  if (idx == -1) return; end;

  str = [str(1:idx-1) rstr str((length(fstr)+1):end)];