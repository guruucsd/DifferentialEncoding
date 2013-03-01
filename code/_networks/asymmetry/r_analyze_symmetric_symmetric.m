function [data] = r_analyze_lewis_elman(net,pats,data)
%

    fprintf('LH Lesion: %5.1f%%; LH Non-lesion: %5.1f%%\n', 100*data.an.l.lh.bg_total, 100*data.an.nl.lh.bg_total);
    fprintf('RH Lesion: %5.1f%%; RH Non-lesion: %5.1f%%\n', 100*data.an.l.rh.bg_total, 100*data.an.nl.rh.bg_total);
    fprintf('__ Lesion: %5.1f%%; __ Non-lesion: %5.1f%%\n', 100*data.an.l.bg_total, 100*data.an.nl.bg_total);
