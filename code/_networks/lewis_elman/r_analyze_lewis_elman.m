function [data] = r_analyze_lewis_elman(net,pats,data)
%
    % Map indices of times that are measured back out to 3D
    %[i,j,k] = find(pats.train.s==1);
    [i,j,k] = ind2sub(size(pats.train.s), pats.train.gb);
    data.an.nl = le_analysis(data.an.nl, pats, i, j, net.sets.train_criterion);
    data.an.l  = le_analysis(data.an.l, pats, i, j, net.sets.train_criterion);

    [i,j,k] = ind2sub(size(pats.train.s), pats.train.gb_lh);
    data.an.l.lh  = le_analysis(data.an.l.lh, pats, i, j, net.sets.train_criterion);
    data.an.nl.lh  = le_analysis(data.an.nl.lh, pats, i, j, net.sets.train_criterion);

    [i,j,k] = ind2sub(size(pats.train.s), pats.train.gb_rh);
    data.an.l.rh  = le_analysis(data.an.l.rh, pats, i, j, net.sets.train_criterion);
    data.an.nl.rh  = le_analysis(data.an.nl.rh, pats, i, j, net.sets.train_criterion);


    % Generate some reports
    fprintf('[INTRA: LH] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.lh.bg_intra, 100*data.an.nl.lh.bg_intra);
    fprintf('[INTRA: RH] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.rh.bg_intra, 100*data.an.nl.rh.bg_intra);
    fprintf('[INTRA: __] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.bg_intra, 100*data.an.nl.bg_intra);
    fprintf('\n');
    fprintf('[INTER: LH] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.lh.bg_inter, 100*data.an.nl.lh.bg_inter);
    fprintf('[INTER: RH] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.rh.bg_inter, 100*data.an.nl.rh.bg_inter);
    fprintf('[INTER: __] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.bg_inter, 100*data.an.nl.bg_inter);
    fprintf('\n');
    fprintf('\n');
return
    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000*data.nl_numbad_intra'./sum(isintra))/10 ));
    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000* l_numbad_intra'./sum(isintra))/10 ));
    fprintf('\n');
    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000*( nl_numbad_intra - l_numbad_intra)'./sum(isintra))/10 ));
    fprintf('\n');
    fprintf('\n');
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000*nl_numbad_inter'./sum(isinter))/10 ));
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000* l_numbad_inter'./sum(isinter))/10 ));
    fprintf('\n');
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000*( nl_numbad_inter - l_numbad_inter)'./sum(isinter))/10 ));
    
 
function l = le_analysis(l, pats, i, j, train_criterion)


    % Now just get the j that's 'intra'
    isintra = ismember(j, find(strcmp(pats.lbls,'intra')));
    isinter = ismember(j, find(strcmp(pats.lbls,'inter')));
    intra_j = find( isintra );
    inter_j = find( isinter );

    l.bits_cor_intra         = (l.abs_diff(intra_j)<=train_criterion);
    l.bits_set_intra         = length(intra_j);
    l.bg_intra               = sum(l.bits_cor_intra)/l.bits_set_intra;

    l.bits_cor_inter         = (l.abs_diff(inter_j)<=train_criterion);
    l.bits_set_inter         = length(inter_j);
    l.bg_inter               = sum(l.bits_cor_inter)/l.bits_set_inter;

    %%

    ui = unique(i);
    l.numbad_intra  = zeros(max(ui),1);
    l.numbad_inter  = zeros(max(ui),1);

    for ii=1:length(ui)
        l.numbad_intra (ui(ii)) = sum( l.abs_diff((i==ui(ii)) & isintra) > train_criterion);
        l.numbad_inter (ui(ii)) = sum( l.abs_diff((i==ui(ii)) & isinter) > train_criterion);
    end;
