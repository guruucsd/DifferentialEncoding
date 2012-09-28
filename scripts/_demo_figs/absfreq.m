

%%Ivry and Robertson Frequency Filtering
close all; clear all;

x=0:10;
ylow=1-0.075*(x-5);
yhigh=1+0.075*(x-5);


subplot(1,4,1);
plot(x,ylow, 'b--', 'LineWidth', 2.0); hold on;
plot(x,yhigh, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {'LSF', 'HSF'});
legend({'RH', 'LH'}, 'Location', 'South');
ylabel('power');
xlabel(sprintf('absolute\nfrequency bias\n '));


z=zeros(size(x));
z(4:8) = 1;
zlow=ylow.*z; zlown = zlow-z*(-1+mean(zlow(zlow>0)));%zlow(zlow>0));
zhigh=yhigh.*z; zhighn = zhigh-z*(-1+mean(zhigh(zhigh>0)));%zhigh(find(zhigh)));

subplot(1,4,2);
plot(x,z, '-k', 'LineWidth', 2.0);
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('task-relevant\nbandpass\n '));

subplot(1,4,3);
plot(x,zlow, 'b--', 'LineWidth', 2.0); hold on;
plot(x,zhigh, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('absolute\nfrequency bias\n '));

subplot(1,4,4);
plot(x,zlown, 'b--', 'LineWidth', 2.0); hold on;
plot(x,zhighn, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('relative\nfrequency bias\n '));




