function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_symmetric(sets)
%function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_symmetric(sets)
% Here, patterns are symmetric on the input, and symmetric on the output.
%   no inter-hemispheric communication is necessary, and no difference in
%   function is forced by the output
%
% Note: this is the Ringo et al. (1994) case

    [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_lewis_elman(sets, 'symmetric-symmetric');

