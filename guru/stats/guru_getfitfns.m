function [fitfn,pmffn,pdffn,mnfn,varfn] = guru_getfitfns(fit_distn, frac, showfig)
%function [fitfn,pmffn,pdffn] = guru_getfitfns(fit_distn)
%
%   frac: minimum height (fraction of max height); by default, use all
%     heights.
%   showfig : whether to show figure during fitting
%
% Given a distribution name, return functions that:
%   fitfn: fit some data to that distribution
%   pmffn: return the probability mass at some bin edges
%   pdffn: return the probability density at some x values

if ~exist('frac','var') || isempty(frac), frac = 0; end;
if ~exist('showfig','var'), showfig = false; end;

switch fit_distn
    case 'lognormal'
        % functions for computing mu and sigma from empirical mean and std
        % p(1) = ln(mn)-p(2).^2/2;
        % p(2) = sqrt(ln(var/mn.^2 + 1))
        %sigmafn = @(mn,var) (sqrt(log(var./(mn.^2)+1)));
        %mufn  = @(mn,var) (log(mn)-log(var./(mn.^2)+1)/2);

        % But we're going to fit these functions numerically.
        pmffn = @(x,p) cdf2pmf(@logncdf, x, p);
        pdffn = @lognpdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.3 0.1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[-0.3 0.1], frac, showfig);
        mnfn  = @(p) exp(p(1)+p(2).^2/2);
        varfn = @(p) (exp(p(2).^2)-1).*exp(2*p(1)+p(2).^2);

    case 'IUBD'
        pmffn = @(x,p) cdf2pmf(@IUBDcdf, x, p);
        pdffn = @IUBDpdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[1 1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[1 1], frac, showfig);

    case 'gamma'
        pmffn = @(x,p) cdf2pmf(@gamcdf, x, p);
        pdffn = @gampdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[6 0.1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[4.5 0.1], frac, showfig);
end;