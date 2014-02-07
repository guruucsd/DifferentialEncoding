function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_lewis_elman(sets, opt)

    % Default: do as done in L&E, 2008
    if ~exist('opt','var'), opt='asymmetric-symmetric'; end;
    
    % From table in lewis & elman (2008)
    % First 16 patterns (rows):  inter
    % Second 16 patterns (rows): intra
    %
    % First column: LH input
    % Second column: LH output
    % Third column: RH input
    % Fourth column: RH output
    %
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

    % Index patterns
    idx.lh.in  = [1:5];
    idx.lh.out = [6:10];
    idx.rh.in  = [11:15];
    idx.rh.out = [16:20];

    
    % randomization procedure
    spats   = char(pats+'0');
    decpats = [bin2dec(spats(:,idx.lh.in)) ... % convert each set of patterns to decimal numbers, in sets of 5
               bin2dec(spats(:,idx.lh.out))  ...
               bin2dec(spats(:,idx.rh.in)) ...
               bin2dec(spats(:,idx.rh.out))];   

    % randomizing outputs
    %newouts = randperm(32)-1;
    %decpats(:,idx.lh.out) = newouts;
    %decpats(:,idx.rh.out) = newouts;
    
    replacmt= randperm(32)-1; %mapping from old #s to new #s
    newdecpats = zeros(size(decpats));
    for ii=0:31, newdecpats(decpats==ii) = replacmt(ii+1); end;

    newpats = reshape( dec2bin(newdecpats)-'0', size(pats) );
    pats    = newpats;
        
    % choose options
    switch opt
        case {'asymmetric-symmetric' 'asymmetric_symmetric'}  % this is the lewis&elman setup
            ;
            
            idx.inter = 1:size(pats,1)/2;
            idx.intra = (idx.inter(end)+1):size(pats,1);
            
        % Reversal of lewis & elman setup
        case {'symmetric-asymmetric' 'symmetric_asymmetric'}
            pats(:,[idx.lh.out idx.lh.in  idx.rh.out idx.rh.in]) = ...
            pats(:,[idx.lh.in  idx.lh.out idx.rh.in  idx.rh.out]);

            idx.inter = 1:size(pats,1)/2;
            idx.intra = (idx.inter(end)+1):size(pats,1);

        % Reverse lewis & elman, then make outputs the same.
        case {'symmetric-symmetric' 'symmetric_symmetric'}
            pats(:,[idx.lh.out idx.lh.in  idx.rh.out idx.rh.in]) = ...
            pats(:,[idx.lh.in  idx.lh.out idx.rh.in  idx.rh.out]);
            
            pats(:,idx.lh.out) = pats(:,idx.rh.out);
            
            idx.inter = [];
            idx.intra = 1:size(pats,1);
            
        % Randomize outputs.  Now, Inputs are 4-way ambiguous,
        %   but hemisphere outputs will not be
        case {'asymmetric-asymmetric' 'asymmetric_asymmetric'}
            pats(:,idx.lh.out) = pats((randperm(32)),idx.lh.out);
            
            idx.inter = 1:size(pats,1)/2;
            idx.intra = (idx.inter(end)+1):size(pats,1);

        otherwise
            error('Unknown stimulus option: %s', opt);
    end;
    
    
    %% Repackage for output

    % Split into input/output, revalue to -1 1
    in_pats  = -1+2*pats(:,[idx.lh.in  idx.rh.in]);
    out_pats = -1+2*pats(:,[idx.lh.out idx.rh.out]);

    % Label patterns
    pat_lbls            = cell(size(pats,1),1);
    pat_lbls(idx.inter) = {'inter'};
    pat_lbls(idx.intra) = {'intra'};
    
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);
    
    
