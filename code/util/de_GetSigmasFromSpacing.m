function sigma = de_GetSigmasFromSpacing(spacing)
%
%
%
    nSigmas = 2;
    mean_spacing = spacing.mean;
    maxdiffpct = spacing.maxdiffpct;

    % Compute the spacings desired
    min_spacing = mean_spacing*(1-maxdiffpct/2);
    max_spacing = mean_spacing*(1+maxdiffpct/2);
    spacings = linspace(min_spacing, max_spacing, nSigmas);

    % Empirically, average spacing comparison of sigma(2) vs. sigma(1) is sqrt(sigma(2)/sigma(1))
    % for 2D sigma
    dist_fn = @(sig) mean(sqrt(sum( mvnrnd(zeros(1, ndims(sig)), sig, 1000000).^2, 2)));
    start_dist = 1.2918; %mean(sqrt(sum( mvnrnd([0 0], [1.5 0; 0 1/1.5], 1000000).^2, 2)))
    sigma = (spacings / start_dist) .^2;

    % now test the result
    for si=1:length(sigma)
        fprintf('Desired distance: %f; actual (estimated): %.3f\n', spacings(si), dist_fn(sigma(si)*[1.5 0; 0 1/1.5]));
    end;
