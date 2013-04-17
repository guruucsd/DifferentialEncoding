function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_asymmetric_symmetric(sets)
%function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_asymmetric_asymmetric(sets)
% Here, patterns are asymmetric on the input, and symmetric on the output.
%
% Note: this is the Lewis & Elman (2008) case

    [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_lewis_elman(sets, 'asymmetric_symmetric');
