function de_SaveXLS(fn, stats, title)
%
  error('NYI');
  if (exist('fn','file'))
    [type,sheets] = xlsfinfo(fn);
  end;

  xlswrite(fn, title, stats, 'B1');
  xlswrite({'L+S-', 'L-S+', stats, 'B2');

  startNum = 3;
  for i=1:length(stats)
    xlswrite(fn, stats, title, sprintf('B%d', startNum)))
    startNum = startNum + size(stats{i},1);
  end;
