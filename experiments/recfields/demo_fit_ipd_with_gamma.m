% Plot how inter-patch distance (to nearest neighbor) changes as a function
%    of sigma and # connections.

%clear all;
sigs = [0.5 1:10];
nconns = 2:3:20;

% Cached results.
if ~exist('est_means','var')
    est_means  = zeros(length(sigs),length(nconns));
    emp_means  = zeros(length(sigs),length(nconns));
    gam_params = zeros([2 size(est_means)]);
end;

for si=1:length(sigs)
    for ni=1:length(nconns)
        if ~emp_means(si,ni)  % Re-use 
            [gam_params(:,si,ni), emp_means(si,ni)] =  fit_neighbor_dist(sigs(si), nconns(ni), 10000);
        end;
        est_means(si,ni) = prod(gam_params(:,si,ni)); % gamma mean: product of parameters
        fprintf('[%4.1f %2d]: Empirical vs. estimated means: %5.3f vs. %5.3f\n', sigs(si), nconns(ni), emp_means(si,ni), est_means(si,ni));
    end;
end;


%
figure('Position',[   175   -21   953   705]); 

% Estimated mean inter-patch distance,
%   fit with gamma distribution.
subplot(2,2,1);
imagesc(emp_means);
xlabel('# conns');
ylabel('sigmas');
title('Empirical mean inter-patch distance.');
set(gca, 'xtick', 1:length(nconns), 'xticklabel', nconns);
set(gca, 'ytick', 1:length(sigs),   'yticklabel', sigs);
colorbar;

% Log plot of means--is it a plane?
subplot(2,2,2);
[Y, X] = meshgrid(nconns,sigs);
x=log(X(:)); y=log(Y(:)) ; z=log(emp_means(:));
[~,gz]= fit_plane(x,y,z);
surf(log(X),log(Y),log(emp_means));
hold on;
surf(log(X),log(Y), gz(log(X), log(Y)));
axis tight;
xlabel('log(# conns)');
ylabel('log(sigmas)');
title('Mean inter-patch distance (empirical, compared to fitted plane)')


% Same thing, but now with estimated means.
subplot(2,2,3);
imagesc((est_means))
xlabel('# conns');
ylabel('sigmas');
title('mean inter-patch distance (fitted via gamma).');
set(gca, 'xtick', 1:length(nconns), 'xticklabel', nconns);
set(gca, 'ytick', 1:length(sigs),   'yticklabel', sigs);
colorbar;

subplot(2,2,4);
[Y,X] = meshgrid(nconns,sigs);
x=log(X(:)); y=log(Y(:)); z=log(est_means(:));
[~,gz]= fit_plane(x,y,z);
surf(log(X),log(Y),log(est_means));
hold on;
surf(log(X),log(Y),gz(log(X),log(Y)))
axis tight;
xlabel('log(# conns)');
ylabel('log(sigmas)');
title('Mean inter-patch distance (mean fitted via gamma, compared to fitted plane)')
