% Decreasing noise over development
figure('position', [360   227   289   250]); set(gca, 'fontSize', 14);
plot(1:2000, [0.01*ones(1,250) 0.01*linspace(1,0,750) zeros(1,1000)], 'LineWidth', 3);
set(gca, 'ylim', [-0.0005 0.0125], 'ytick', [0 0.005 0.01], 'yticklabel', {'0%', '0.5%', '1%'});
xlabel('timesteps', 'FontSize', 16);
ylabel('% noise', 'FontSize', 16);

% Constant noise
figure('position', [360   227   289   250]); set(gca, 'fontSize', 14);
plot(1:1000, [0.01*ones(1,1000)], 'LineWidth', 3);
set(gca, 'ylim', [-0.0005 0.0125], 'ytick', [0 0.005 0.01], 'yticklabel', {'0%', '0.5%', '1%'});
xlabel('timesteps', 'FontSize', 16);
ylabel('% noise', 'FontSize', 16);

