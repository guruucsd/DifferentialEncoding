function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_random(sets)
%

    pats = single([ repmat([ones(1,1);-ones(1,1)], [16 1]) ...
        repmat([ones(2,1);-ones(2,1)], [8 1]) ...
        repmat([ones(4,1);-ones(4,1)], [4 1]) ...
        repmat([ones(8,1);-ones(8,1)], [2 1]) ...
        repmat([ones(16,1);-ones(16,1)],[1 1]) ]);
    
    if (~isfield(sets,'npat'))
        sets.npat = size(pats,1);
    end;
    
    in_pats  = pats( guru_randperm( size(pats,1), sets.npat), [1:end 1:end] ); %duplicate patterns
    out_pats = pats( guru_randperm( size(pats,1), sets.npat), [1:end 1:end] ); %duplicate patterns
    pat_cls  = ones(size(in_pats,1),1);
    pat_lbls = repmat({'random'}, [size(in_pats,1) 1]);
    
    pat_idx  = [];