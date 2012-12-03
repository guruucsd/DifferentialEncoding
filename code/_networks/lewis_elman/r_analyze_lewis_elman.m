function [data] = r_analyze_lewis_elman(net,pats,data)
%

    % Map indices of times that are measured back out to 3D
    %[i,j,k] = find(pats.train.s==1);
    [i,j,k] = ind2sub(size(pats.train.s), pats.train.gb);

    % Now just get the j that's 'intra'
    isintra = ismember(j, find(strcmp(pats.lbls,'intra')));
    isinter = ismember(j, find(strcmp(pats.lbls,'inter')));
    intra_j = find( isintra );
    inter_j = find( isinter );


    % Now, 
    l = data.an.l;
    
    l.bits_cor_intra         = (l.abs_diff(intra_j)<=net.sets.train_criterion);
    l.bits_set_intra         = length(intra_j);
    l.bg_intra               = sum(l.bits_cor_intra)/l.bits_set_intra;

    l.bits_cor_inter         = (l.abs_diff(inter_j)<=net.sets.train_criterion);
    l.bits_set_inter         = length(inter_j);
    l.bg_inter               = sum(l.bits_cor_inter)/l.bits_set_inter;

    data.an.l = l; %clear('l');


    % Repeat, 
    nl = data.an.nl;
    
    nl.bits_cor_intra         = (nl.abs_diff(intra_j)<=net.sets.train_criterion);
    nl.bits_set_intra         = length(intra_j);
    nl.bg_intra               = sum(nl.bits_cor_intra)/nl.bits_set_intra;

    nl.bits_cor_inter         = (nl.abs_diff(inter_j)<=net.sets.train_criterion);
    nl.bits_set_inter         = length(inter_j);
    nl.bg_inter               = sum(nl.bits_cor_inter)/nl.bits_set_inter;

    data.an.nl = nl; %clear('nl');


    % Generate some reports
    fprintf('[INTRA] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.bg_intra, 100*data.an.nl.bg_intra);
    fprintf('[INTER] Lesion: %5.1f%%; Non-lesion: %5.1f%%\n', 100*data.an.l.bg_inter, 100*data.an.nl.bg_inter);

    
    ui = unique(i);
    nl_numbad_intra = zeros(max(ui),1);
    nl_numbad_inter = zeros(max(ui),1);
    l_numbad_intra  = zeros(max(ui),1);
    l_numbad_inter  = zeros(max(ui),1);

    for ii=1:length(ui)
        nl_numbad_intra(ui(ii)) = sum(nl.abs_diff((i==ui(ii)) & isintra) > net.sets.train_criterion);
        nl_numbad_inter(ui(ii)) = sum(nl.abs_diff((i==ui(ii)) & isinter) > net.sets.train_criterion);
        l_numbad_intra (ui(ii)) = sum( l.abs_diff((i==ui(ii)) & isintra) > net.sets.train_criterion);
        l_numbad_inter (ui(ii)) = sum( l.abs_diff((i==ui(ii)) & isinter) > net.sets.train_criterion);
    end;
    
    
%    keyboard;
%    nl = data.nolesion; 
%    l  = data.lesion;
    
 %   inter_pats = strcmp(pats.lbls,'inter');
 %   nl_numbad_intra = squeeze(sum(nl.E(:,~inter_pats,:)>0.5.^2,2)); 
 %   nl_numbad_inter = squeeze(sum(nl.E(:, inter_pats,:)>0.5.^2,2)); 
 %   l_numbad_intra  = squeeze(sum( l.E(:,~inter_pats,:)>0.5.^2,2)); 
 %   l_numbad_inter  = squeeze(sum( l.E(:, inter_pats,:)>0.5.^2,2)); 

    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000*nl_numbad_intra'./sum(isintra))/10 ));
    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000* l_numbad_intra'./sum(isintra))/10 ));
    fprintf('\n');
    fprintf('[INTRA] %% wrong (in time): %s\n', mat2str( round(1000*( nl_numbad_intra - l_numbad_intra)'./sum(isintra))/10 ));
    fprintf('\n');
    fprintf('\n');
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000*nl_numbad_inter'./sum(isinter))/10 ));
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000* l_numbad_inter'./sum(isinter))/10 ));
    fprintf('\n');
    fprintf('[INTER] %% wrong (in time): %s\n', mat2str( round(1000*( nl_numbad_inter - l_numbad_inter)'./sum(isinter))/10 ));
    
    