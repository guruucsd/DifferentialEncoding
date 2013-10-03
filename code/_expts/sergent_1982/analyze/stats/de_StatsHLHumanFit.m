function humfit = de_StatsHLPerfDiff(allstats)
%
%

  humfit = zeros(size(allstats));
  for i=1:size(allstats,1)
    for j=1:size(allstats,2)
      humfit(i,j) = allstats{i,j}.rej.hum;
    end;
  end;
