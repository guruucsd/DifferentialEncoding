figure('position', [360   227   571   451]); set(gca, 'fontSize', 16);
plot(1:2000, [0.01*ones(1,250) 0.01*linspace(1,0,750) zeros(1,1000)], 'LineWidth', 3);
set(gca, 'ylim', [-0.0005 0.0125], 'ytick', [0 0.005 0.01], 'yticklabel', {'0%', '0.5%', '1%'});
xlabel('timesteps');
ylabel('% noise');

