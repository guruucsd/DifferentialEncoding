function [rho,pval] = de_StatsHLPerfDiffVsHumanFit(allstats)
%
%

    perfdiff = de_StatsHLPerfDiff(allstats);
    humfit   = de_StatsHLHumanFit(allstats);
    
    [rho,pval] = corr(humfit(:),perfdiff(:), 'tail', 'both');