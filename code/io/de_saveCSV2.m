function de_SaveCSV2(fn, stats, delim, title, mSets)
%

  if (~exist('delim','var'))
    delim = '\t';
  end;

  % open file
  %if (exist(guru_smartfn(fn), 'file'))
  %  unix(['rm ' guru_smartfn(fn)]);
  %end;

  [fh,msg] = fopen(fn, 'w');
  if (fh == -1), error(msg); end;

  % print title
  if (exist('title','var'))
    fprintf(fh, [title '\n']);
  end;

  % print header
  fprintf(fh, ['run' delim 'hemisphere' delim 'global_target' delim 'local_target' delim 'nConns' delim 'nHidden' '\n']);

  % print data
  for s=length(stats.raw.basics.ls):-1:1 %RH=1,LH=2
    ls = stats.raw.basics.ls{s};


    for r=1:size(ls,1)
      fprintf(fh, ['%d' delim  '%d'], r,1+length(stats.raw.basics.ls)-s);
      fprintf(fh, [delim '%6.5f' delim '%6.5f'], ...
                  ls(r,3), ... % L+S- big assumptions here, should parameterize!!
                  ls(r,4));    % L-S+  here too!
      fprintf(fh, [delim '%4d' delim '%4d\n'], ...
                  mSets.nConns, mSets.nHidden);
    end;
  end;

  fclose(fh);
