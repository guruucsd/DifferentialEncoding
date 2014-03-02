function [pct_proj] = predict_pct_proj(brwt,bvol)
%function [pct_proj] = predict_pct_proj(brwt,bvol)
%
% Predict the pct of neurons projecting into the white matter.
%
% Currently hard-coded to 0.3

    if ~exist('bvol','var') || isempty(bvol), bvol = predict_bvol(brwt); end;
    if ~exist('brwt','var') || isempty(brwt), brwt = predict_bwt(bvol); end;

    pct_proj = 0.3*ones(size(brwt));