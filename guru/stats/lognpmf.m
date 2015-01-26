function distn = lognpmf(x, mu, sigma, bins)
    if ~exist('bins','var'), bins = x; end; %assume that what we're asked for constitutes all the bins
    
    distn = (diff([0 logncdf([x(1:end-1) inf], mu, sigma)]));

    %if any(isnan(distn)), error('NAN?'); end;