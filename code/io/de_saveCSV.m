function de_saveCSV(fn, stats, delim, title)
%

  if (~exist('delim','var'))
    delim = '\t';
  end;
  
  % open file
  [fh,msg] = fopen(guru_smartfn(fn), 'w');
  if (fh == -1), error(msg); end;
  
  % print title
  if (exist('title','var'))
    fprintf(fh, [title '\n']);
  end;
  
  % print header
  fprintf(fh, [delim 'L+S-' delim 'L-S+' '\n']);
  
  % print data
  for s=1:length(stats.raw.basics.ls)
    ls = stats.raw.basics.ls{s};
    switch(s)
      case 1, netname = 'RHnet';
      case 2, netname = 'LHnet';
      otherwise, netname = '?';
    end;

    for r=1:size(ls,1)
      fprintf(fh, [netname ' run %d'], r);
      fprintf(fh, [delim '%6.5f' delim '%6.5f\n'], ...
                  ls(r,3), ...
                  ls(r,4));
    end;
  end;
  
  fclose(fh);