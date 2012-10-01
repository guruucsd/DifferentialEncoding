

%%Ivry and Robertson Frequency Filtering
close all; clear all;

x=0:10;
ylow=1-0.075*(x-5);
yhigh=1+0.075*(x-5);


subplot(2,4,1);
plot(x,ylow, 'b--', 'LineWidth', 2.0); hold on;
plot(x,yhigh, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
legend({'RH', 'LH'}, 'Location', 'South');
ylabel('power');
xlabel(sprintf('absolute\nfrequency bias'));

subplot(2,4,5);
plot(x,ylow, 'b--', 'LineWidth', 2.0); hold on;
plot(x,yhigh, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {'LSF', 'HSF'});
legend({'RH', 'LH'}, 'Location', 'South');
ylabel('power');


z=zeros(size(x));
z(3:6) = 1;
zlow=ylow.*z; zlown = zlow-z*(-1+mean(zlow(zlow>0)));%zlow(zlow>0));
zhigh=yhigh.*z; zhighn = zhigh-z*(-1+mean(zhigh(zhigh>0)));%zhigh(find(zhigh)));

subplot(2,4,2);
plot(x,z, '-k', 'LineWidth', 2.0);
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('task-relevant\nbandpass'));

subplot(2,4,3);
plot(x,zlow, 'b--', 'LineWidth', 2.0); hold on;
plot(x,zhigh, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('\n(freq bias)*bandpass'));

subplot(2,4,4);
plot(x,zlown, 'b--', 'LineWidth', 2.0); hold on;
plot(x,zhighn, 'r-', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});
xlabel(sprintf('differences in\n(freq bias)*bandpass'));


z=zeros(size(x));
z(6:9) = 1;
zlow=ylow.*z; zlown = zlow-z*(-1+mean(zlow(zlow>0)));%zlow(zlow>0));
zhigh=yhigh.*z; zhighn = zhigh-z*(-1+mean(zhigh(zhigh>0)));%zhigh(find(zhigh)));
%
% Logic for zlown/zhighn: 
%   - mean only at nonzero elements: want to center responses around zero (ignoring zero responses; not in task-relevant range)
%   - -1: want to transpose entire range UP by 1, to visually match rest of
%         demo
%   - Multiply by z: easy way to apply only at frequency band

subplot(2,4,6);
plot(x,z, '-k', 'LineWidth', 2.0);
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});

subplot(2,4,7);
z=zeros(size(x));
plot(x,zhigh, 'r-', 'LineWidth', 2.0); hold on;
plot(x,zlow, 'b--', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});

subplot(2,4,8);
plot(x,zhighn, 'r-', 'LineWidth', 2.0); hold on;
plot(x,zlown, 'b--', 'LineWidth', 2.0); hold on;
set(gca, 'ylim', [0 1.5], 'FontSize', 14, 'ytick', [], 'xtick', [2 8.5], 'xticklabel', {' ', ' '});



