function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_lewis_elman(sets)
%

    % From table in lewis & elman (2008)
    pats = [ 1 0 0 0 1   0 0 0 0 1      0 1 0 0 0   0 0 0 0 1
             0 1 0 0 0   0 1 1 1 0      0 0 1 0 0   0 1 1 1 0
             1 1 1 1 0   1 0 0 0 1      1 0 1 0 1   1 0 0 0 1
             1 0 0 0 1   0 1 0 1 1      1 0 1 0 1   0 1 0 1 1
             1 1 0 1 1   1 0 0 1 1      0 0 1 0 0   1 0 0 1 1
             1 1 1 1 0   1 0 1 1 0      0 1 0 0 0   1 0 1 1 0
             0 1 0 0 0   1 0 1 1 1      1 0 1 0 1   1 0 1 1 1
             1 1 1 1 0   1 1 0 0 1      0 0 0 0 0   1 1 0 0 1
             1 1 0 1 1   1 1 0 1 0      0 1 0 0 0   1 1 0 1 0
             1 0 0 0 1   0 1 0 0 0      0 0 1 0 0   0 1 0 0 0
             1 1 0 1 1   1 1 1 0 0      1 0 1 0 1   1 1 1 0 0
             0 1 0 0 0   1 1 1 0 1      0 1 0 0 0   1 1 1 0 1
             1 0 0 0 1   0 1 0 0 1      0 0 0 0 0   0 1 0 0 1
             0 1 0 0 0   1 1 1 1 1      0 0 0 0 0   1 1 1 1 1
             1 1 1 1 0   0 0 1 0 0      0 0 1 0 0   0 0 1 0 0
             1 1 0 1 1   0 0 1 1 0      0 0 0 0 0   0 0 1 1 0
             ...               
             0 0 0 1 0   0 0 0 0 0      0 0 0 1 0   0 0 0 0 0
             0 1 0 1 0   0 0 0 1 0      1 0 1 1 0   0 0 0 1 0
             0 0 0 0 0   0 0 0 1 1      1 0 0 0 1   0 0 0 1 1
             1 0 0 1 1   0 0 1 0 1      0 0 0 1 1   0 0 1 0 1
             0 1 1 0 1   0 0 1 1 1      1 1 0 1 0   0 0 1 1 1
             1 1 0 1 0   0 1 0 1 0      0 0 1 1 1   0 1 0 1 0
             0 0 0 0 1   0 1 1 0 0      0 1 0 1 0   0 1 1 0 0
             1 1 1 0 1   0 1 1 0 1      1 1 1 0 1   0 1 1 0 1
             0 1 1 0 0   0 1 1 1 1      1 0 0 1 1   0 1 1 1 1
             1 1 0 0 0   1 0 0 0 0      0 1 0 1 1   1 0 0 0 0
             1 0 1 1 1   1 0 0 1 0      1 0 0 0 0   1 0 0 1 0 
             1 0 0 0 0   1 0 1 0 0      1 1 1 0 0   1 0 1 0 0
             0 0 1 0 0   1 0 1 0 1      0 1 1 0 1   1 0 1 0 1
             0 0 1 1 0   1 1 0 0 0      0 0 1 0 1   1 1 0 0 0
             0 1 0 0 1   1 1 0 1 1      0 1 0 0 1   1 1 0 1 1
             1 0 1 0 1   1 1 1 1 0      1 1 0 0 1   1 1 1 1 0
            ];
    pats(~pats) = -1; %
    in_pats = pats(:,[1:5 11:15]);
    out_pats = pats(:, [6:10 16:20]);
    
    pat_idx.inter = 1:size(pats,1)/2;
    pat_idx.intra = size(pats,1)/2+1:size(pats,1);

    % First half are interhemispheric, second half intrahemispheric
    pat_lbls                = cell(size(pats,1),1);
    pat_lbls(pat_idx.inter) = {'inter'};
    pat_lbls(pat_idx.intra) = {'intra'};
    
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);
    
    %, out_pats, pat_cls, pat_lbls, pat_idx

    intra_pats = strcmp(pat_lbls, 'intra');
    in_pats = in_pats(intra_pats,:);
    out_pats = out_pats(intra_pats,:);
    pat_cls = [2];
    pat_lbls = pat_lbls(intra_pats);
    pat_idx.inter = [];
