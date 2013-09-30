function [params] = fit_distns(X,Y,fit_type,frac)
%function [params] = fit_distns(X,Y,fit_type,frac)
%
% could add Yfit

    if ~exist('frac','var'), frac=0; end;

    % normalize distribution
    Y = Y./repmat(sum(Y,2),[1 size(Y,2)]);

    % Choose the appropriate functions
    switch fit_type
        case 'lognormal'
            % functions for computing mu and sigma from empirical mean and std
            % p(1) = ln(mn)-p(2).^2/2;
            % p(2) = sqrt(ln(var/mn.^2 + 1)) 
            sigmafn = @(mn,var) (sqrt(log(var./(mn.^2)+1)));
            mufn  = @(mn,var) (log(mn)-log(var./(mn.^2)+1)/2);

            %Estimate lognormal parameters based on empirical mean and variance
            %mp_emp = [mufn(bi_fig9_myelinated_mean, bi_fig9_myelinated_var)'; ...    % myelinated
            %          sigmafn(bi_fig9_myelinated_mean, bi_fig9_myelinated_var)'];
            %
            %up_emp = [mufn(bi_fig9_unmyelinated_mean, bi_fig9_unmyelinated_var)'; ... % unmyelinated
            %sigmafn(bi_fig9_unmyelinated_mean, bi_fig9_unmyelinated_var)';];

            % But we're going to fit these functions numerically.
            pmffn = @(x,p) cdf2pmf(@logncdf, x,p);
            pdffn = @lognpdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.3 0.1]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[-0.3 0.1]);

        case 'IUBD'
            pmffn = @(x,p) cdf2pmf(@IUBDcdf, x, p);
            pdffn = @IUBDpdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[1 1]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[1 1]);

        case 'gamma'
            pmffn = @(x,p) cdf2pmf(@gamcdf, x, p);
            pdffn = @gampdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[6 0.1]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[6 0.1]);
    end;


    % Do each fit individually
    ndates = size(Y,1);
    params = nan(2,ndates);

    f = figure; set(gcf, 'position', [27          17        1254         667])
    for si=1:ndates
        end_idx = find(Y(si,:)>=(frac*max(Y(si,:))), 1, 'last');

        figure(f); subplot(2,ceil(ndates/2),si);
        if ~isempty(end_idx)
            params(:,si) = fitfn(Y(si,1:end_idx-1), X(1:end_idx-1));
        end;
    end;