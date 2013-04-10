close all; clear all;

figure;
t    = [5   15   25  35  45  55  65  75];%0 15 20 25 30 35 40 45 50 55 60 65 70 75];
%aay  = [100 100  95  95  95  95  95  95];
%ppy  = [100 100  95  85  85  85  85  85];
%pay  = [100 100  95  90  87  87  87  87];
%apy  = [100 100  95  92  92  92  92  92];

aay  = [101.5 101.5  101.5  101.5  101.5  101.5  101.5  101.5];
ppy  = [100.5 100.5  100.5  100.5  100.5  100.5  100.5  100.5];
pay  = [99.5  99.5  99.5  99.5  99.5  99.5  99.5  99.5];
apy  = [98.5  98.5  98.5  98.5  98.5  98.5  98.5  98.5];

aan  = [50  50   50  50  50  50  50  50];
%aan  = [50  45   45  45  45  45  45  45];
ppn  = [20  10   1/32  1/32  1/32  1/32  1/32  1/32];
pan  = [25  15   5     1/32  1/32  1/32  1/32  1/32];
apn  = [30  20   10    1/32  1/32  1/32  1/32  1/32];

subplot(1,2,1); %b g r c ;ppy;pay;apy]
plot(t, aay, 'b-.', 'LineWidth', 2); hold on;
plot(t, apy, 'c--', 'LineWidth', 2);
plot(t, pay, 'r-', 'LineWidth', 2);
plot(t, ppy, 'g:', 'LineWidth', 2);
set(gca, 'xlim', [0 max(t)], 'ylim', [0 105], 'ytick', [0 50 100], 'FontSize', 14);
xlabel('time-step'); ylabel('% correct');
title('Intra- Solvable', 'FontSize', 20);

subplot(1,2,2);
plot(t, aan, 'b-.', 'LineWidth', 2); hold on;
plot(t, apn, 'c--', 'LineWidth', 2);
plot(t, pan, 'r-', 'LineWidth', 2);
plot(t, ppn, 'g:', 'LineWidth', 2);
legend({'Association-Association', 'Primary-Primary', 'Primary-Association', 'Association-Primary'}, 'Location', 'NorthEast');
set(gca, 'xlim', [0 max(t)], 'ylim', [0 105], 'ytick', [0 25 50], 'FontSize', 14);
xlabel('time-step'); 
title('Intra- NOT Solvable', 'FontSize', 20);
