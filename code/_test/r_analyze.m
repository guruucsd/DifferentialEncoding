function [an] = r_analyze(net, pats, d)

    % Was passed a particular dataset & result; do the actual calculations
    if (isfield(d,'ypat'))
        an.abs_diff         = abs(d.ypat(pats.gb)-pats.d(pats.gb));
        an.max_diff         = max(an.abs_diff(:));
        an.bits_cor         = (an.abs_diff<net.sets.train_criterion);
        an.bits_set         = length(pats.gb);
    
        an.bg_total  = sum(an.bits_cor)/an.bits_set;
        return;
    end;
    
    % Analyze each struture, then report        
    if (isfield(d,'lesion'))
        
        % Generic analyses
        [an.l]  = r_analyze(net, pats.(d.lesion.pats), d.lesion);
        [an.nl] = r_analyze(net, pats.(d.nolesion.pats), d.nolesion);
        d.an = an;
        
        % Generic reports
        %d.lesion.avgerr - d.nolesion.avgerr         % Hemispheric diff in activation
        
        % Sub-analysis
        net.fn.analyze(net, pats, d);
    end; 