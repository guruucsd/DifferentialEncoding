function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_asymmetric(sets)
%function [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_symmetric_asymmetric(sets)
% Here, patterns are symmetric on the input, and asymmetric on the output.

    [in_pats, out_pats, pat_cls, pat_lbls, pat_idx] = r_pats_lewis_elman(sets, 'symmetric_asymmetric');
