function [data] = r_analyze_lewis_elman(net,pats,data)
%

    fprintf('Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.bg_total, 100*data.an.nl.bg_total);
