function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_de_1D(sets)
%
    if (~isfield(sets,'nbpp')),     sets.nbpp     = 3; end;
    if (~isfield(sets,'pres_loc')), sets.pres_loc = {'LVF' 'CVF' 'RVF'}; end;
    if (~iscell (sets.pres_loc)),   sets.pres_loc = {sets.pres_loc}; end;

    if (~isfield(sets,'target_set'))
        switch (sets.nbpp)
            case 3, sets.target_set     = [3 6];    % sum [1 1 1]
            case 4, sets.target_set     = [3 8];    %[x x 0 x]; sum [1 1 0 1]
        end; 
    elseif (isempty(sets.target_set))
        sets.target_set = 1:2^sets.nbpp;
    end;
    if (~isfield(sets,'distracter_set'))
        switch (sets.nbpp)
            case 3, sets.distracter_set = [4 5]; %[0 1 0]   [1 0 1]   vs [1 0 0]   [0 1 1]
            case 4, sets.distracter_set = [5 6]; %[0 1 0 0] [1 0 0 1] vs [1 1 0 0] [0 0 0 1]
        end;
    end;
    
    sel_pats = [sets.target_set, sets.distracter_set];
    
    
    % Make the patterns (local)
    nbpl   = 1+mod(sets.nbpp,2); %1 bit per position for evens, 2 bits per position for odd
    
    npats    = 2^sets.nbpp;
    bitstr   = dec2bin(0:(npats-1));
    
    % Now select the patterns to use
    npats    = length(sel_pats);
    bitstr   = bitstr(sel_pats,:);
    
    pats_raw = str2double(num2cell(bitstr));
    pats     = bitstr(:,ceil(0.5:(1/nbpl):sets.nbpp)); % duplicate any columns necessary
    pats     = str2double(num2cell(pats));
    pats(~pats) = -1;

    % Even
    if (mod(sets.nbpp,2)==0)    
        error('nyi');
        % Now use local configs to create global patterns made of local patterns
        nbanks    = 2*sets.nbpp;
        nspacers  = nbanks - 1;
    
        zzzzzzzzz = -ones(1,size(pats,2));
        X         = zeros(npats.^2, nbanks*sets.nbpp + nspacers*1); %5 banks + 2
        Y         = zeros(npats.^2, 2);
        
        for i=1:npats
            for b=1:sets.nbpp
            end; 
            padded_pats_left  = [zeros(npats,1) pats];
            padded_pats_right = [pats zeros(npats,1)];
            half_pat_left     = pats(:,1:sets.nbpp/2);
            half_pat_right    = pats(:,sets.nbpp/2:1:end);
       
            global_pats_left  = [repmat(padded_pats_right,[1 sets.nbpp]) half_pat_left];
            global_pats_right = [half_pat_right repmat(padded_pats_left,[1 sets.nbpp])];
       
            in_pats           = [global_pats_left global_pats_right];
       end;
       
    % Odd
    else
        zzzz     = -ones(1,size(pats,2)); %-1 is the new zero?
        in_pats  = zeros(npats.^2*length(sets.pres_loc), size(pats,2)*(size(pats,2)+1));
        out_pats = zeros(size(in_pats,1),1);
        pat_lbls = cell(size(in_pats,1), 1);

        curpat = 1;
        for g=1:npats
            for l=1:npats
                p = [];
                for b=1:sets.nbpp
                   % If it's the time to put a local pattern into the
                   %    global pattern, then do it!
                   if (pats_raw(g,b)), p = [p pats(l,:)];   
                   else,               p = [p zzzz]; end;
                end;
                
                for i=1:length(sets.pres_loc)
                    switch (sets.pres_loc{i})
                        case 'LVF', in_pats(curpat,:)  = [p repmat(zzzz, [1 sets.nbpp+1])];
                        case 'RVF', in_pats(curpat,:)  = [repmat(zzzz, [1 sets.nbpp+1]) p];
                        case 'CVF', in_pats(curpat,:)  = [repmat(zzzz, [1 (sets.nbpp+1)/2]) p repmat(zzzz, [1 (sets.nbpp+1)/2])];
                        otherwise,  error('unknown location: %s', sets.pres_loc);
                    end;
                    
                    if (any(ismember(g,1:length(sets.target_set)))), gsymb='+'; else, gsymb='-'; end;
                    if (any(ismember(l,1:length(sets.target_set)))), lsymb='+'; else, lsymb='-'; end;
                    
                    out_pats(curpat,:) = any(ismember([g l],1:length(sets.target_set)));

                    pat_lbls{curpat}   = sprintf('%s/L%sS%s', sets.pres_loc{i}, gsymb, lsymb);
                    curpat = curpat + 1;
                end;
            end;
        end;
        
        [~,~,pat_cls] = unique(pat_lbls);
        pat_cls = unique(pat_cls);
    end;            
    
%    in_pats(~in_pats) = -1;
    out_pats(~out_pats) = -1;
    

    
    % get indices;
    rvf_idx_c = strfind(pat_lbls,'RVF'); pat_idx.rvf = false(size(rvf_idx_c));
    lvf_idx_c = strfind(pat_lbls,'LVF'); pat_idx.lvf = false(size(lvf_idx_c));
    cvf_idx_c = strfind(pat_lbls,'CVF'); pat_idx.cvf = false(size(cvf_idx_c));
    gl_idx_c  = strfind(pat_lbls,'L+');  pat_idx.gl  = false(size(gl_idx_c));
    lc_idx_c  = strfind(pat_lbls,'S+');  pat_idx.lc  = false(size(lc_idx_c));
    for i=1:length(pat_lbls)
        pat_idx.rvf(i) = ~isempty(rvf_idx_c{i});
        pat_idx.lvf(i) = ~isempty(lvf_idx_c{i});
        pat_idx.cvf(i) = ~isempty(cvf_idx_c{i});
        pat_idx.gl (i) = ~isempty(gl_idx_c {i});
        pat_idx.lc (i) = ~isempty(lc_idx_c {i});
    end;       
