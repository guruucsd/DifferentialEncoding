% Create a 3D surface plot that shows ipd as a function of sigma and nconn

fc_map = [];
nn_map = [];

sigmas = [1:20];
nconns = [5:5:50];
nsamps = 10000;

for si=1:length(sigmas)
    sigma = sigmas(si);
    
    for ni=1:length(nconns)
        nconn = nconns(ni);
        fprintf('Computing average distances for sigma=%.2f, nconns=%d\n', sigma, nconn);

        fc_avg = [];
        nn_avg = [];
        for ii=1:round(nsamps/nconn)
            pts = mvnrnd([0 0], sigma*[1.5 0; 0 1/1.5], nconn);
            [fc, nn] = de_stats_ipd([], pts);
            fc_avg(ii) = mean(fc);
            nn_avg(ii) = mean(min(nn));
        end;
        
        fc_map(si, ni) = mean(fc_avg);
        nn_map(si, ni) = mean(nn_avg);
    end;
end;

figure('Position', [115         396        1128         382]);

[X, Y] = meshgrid( nconns, sigmas );

subplot(1,2,1); set(gca, 'FontSize', 14);
title('from center map');
surf(X, Y, fc_map);
xlabel('nconn')
ylabel('sigma')
zlabel('average distance from center');

subplot(1,2,2); set(gca, 'FontSize', 14);
title('inter-patch distance map');
surf(X, Y, nn_map);
xlabel('nconn')
ylabel('sigma')
zlabel('average iter-point distance');

