function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_symmetric(sets)
% Here, patterns are symmetric on the input, and symmetric on the output.
%   no inter-hemispheric communication is necessary, and no difference in
%   function is forced by the output

    npats = 32;
    ninput = length(dec2bin(npats-1));
    noutput = ninput;
    
    all_pats = dec2bin(0:npats-1,ninput/2) - '0';

    % Symmetric inputs
    in_pats = repmat( all_pats(randperm(npats),:), [1 2] );
    in_pats(~in_pats) = -1; %
    
    % Asymmetric outputs
    out_pats = repmat( all_pats(randperm(npats),:), [1 2] );
    out_pats(~out_pats) = -1; %
    
    pat_lbls = repmat( {'sym-sym'}, [1 npats] );
    pat_idx  = struct();
    
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);
