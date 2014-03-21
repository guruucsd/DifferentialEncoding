function d = IUBDpdf(s,a,b)

    d = (1./(2*besselk(0,2*sqrt(a.*b))) .* exp(-b.*s - a./s)./s); % via eqn 13

    d(isnan(d)) = 0; % happens at 0