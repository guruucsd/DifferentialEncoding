function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_asymmetric_asymmetric(sets)
%function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_asymmetric_asymmetric(sets)
% Here, patterns are asymmetric on the input, and asymmetric on the output.


    [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_lewis_elman(sets, 'symmetric_symmetric');
