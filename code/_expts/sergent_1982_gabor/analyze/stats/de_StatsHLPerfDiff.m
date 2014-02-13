function perfdiff = de_StatsHLPerfDiff(allstats)
%
%

  perfdiff = zeros(size(allstats));
  for i=1:size(allstats,1)
    for j=1:size(allstats,2)
      perfdiff(i,j) = -diff(sum(allstats{i,j}.rej.basics.bars(3:4,:))); %(LH-RH)
    end;
  end;

