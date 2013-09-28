function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_asymmetric(sets)
% Here, patterns are symmetric on the input, and symmetric on the output.
%   no inter-hemispheric communication is necessary, but differences
%   in the hemispheres can emerge, due to different outputs

    npats = 32;
    ninput = length(dec2bin(npats-1));
    noutput = ninput;
    
    all_pats = dec2bin(0:npats-1,ninput/2) - '0';

    % Symmetric inputs
    in_pats = [all_pats(randperm(npats),:) all_pats(randperm(npats),:)];
    in_pats(~in_pats) = -1; %
    
    % Asymmetric outputs
    out_pats = [all_pats(randperm(npats),:) all_pats(randperm(npats),:)];
    out_pats(~out_pats) = -1; %
    
    pat_lbls = repmat( {'asym-asym'}, [1 npats] );
    pat_idx  = struct();
    
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);
