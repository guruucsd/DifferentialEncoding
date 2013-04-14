function [fitfn,pmffn,pdffn] = getfitfns(fit_type)

switch fit_type
    case 'lognormal'
        % functions for computing mu and sigma from empirical mean and std
        % p(1) = ln(mn)-p(2).^2/2;
        % p(2) = sqrt(ln(var/mn.^2 + 1)) 
        sigmafn = @(mn,var) (sqrt(log(var./(mn.^2)+1)));
        mufn  = @(mn,var) (log(mn)-log(var./(mn.^2)+1)/2);

        % But we're going to fit these functions numerically.
        pmffn = @(x,p1,p2) cdf2pmf(@logncdf, x, p1, p2);
        pdffn = @lognpdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.3 0.1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[-0.3 0.1]);

    case 'IUBD'
        pmffn = @(x,p1,p2) cdf2pmf(@IUBDcdf, x, p1, p2);
        pdffn = @IUBDpdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[1 1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[1 1]);

    case 'gamma'
        pmffn = @(x,p1,p2) cdf2pmf(@gamcdf, x, p1, p2);
        pdffn = @gampdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[6 0.1]);
        fitfn = @(d,b) fitpmf(pmffn,d,b,[6 0.1]);
end;