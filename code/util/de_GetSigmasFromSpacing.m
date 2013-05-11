function sigma = de_GetSigmasFromSpacing(spacing)
%
%
%
    nsigmas = 2;
    mean_spacing = 2;
    maxdiffpct = 0.3;
    nconns = 10;
    
    % Compute the spacings desired
    min_spacing = mean_spacing*(1-maxdiffpct/2);
    max_spacing = mean_spacing*(1+maxdiffpct/2);
    spacings = linspace(min_spacing, max_spacing, nsigmas);
    
    % Compute sigmas from desired spacings
    @errfn = 
    sigma = [4 10];