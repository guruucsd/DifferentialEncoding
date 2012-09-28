clear all; close all;

%% Christman
x = linspace(-pi, pi, 31);
f0 = 1.88* (2*pi);
f1 = 2.54* (2*pi);
f2 = 3.28 * (2*pi);
f3 = 4.50 * (2*pi);
f4 = 7.50 * (2*pi);

minmax = [0 1];

y0 = mean(minmax) + (diff(minmax)/2)*sin((f0/(2*pi)) * x);
y1 = mean(minmax) + (diff(minmax)/2)*sin((f1/(2*pi)) * x);

y2 = mean(minmax) + (diff(minmax)/2)*sin((f2/(2*pi)) * x);

y3 = mean(minmax) + (diff(minmax)/2)*sin((f3/(2*pi)) * x);
y4 = mean(minmax) + (diff(minmax)/2)*sin((f4/(2*pi)) * x);

figure;

%subplot(2,3,1);
subplot(3,2,1);
imshow( repmat( (y0+y1)/2, length(x), 1) );
xlabel('f0+f1');

subplot(3,2,3);
%subplot(2,3,2);
imshow( repmat( (y0+y1+y2)/3, length(x), 1) );
xlabel('f0+f1+f2');

subplot(3,2,5);
%subplot(2,3,3);
imshow( repmat(y2, length(x), 1) );
xlabel('f2 (relatively HSF)');


subplot(3,2,2);
%subplot(2,3,4);
imshow( repmat((y3+y4)/2, length(x), 1) );
xlabel('f3+f4');

subplot(3,2,4);
%subplot(2,3,5);
imshow( repmat((y2+y3+y4)/3, length(x), 1) );
xlabel('f2+f3+f4');

subplot(3,2,6);
%subplot(2,3,6);
imshow( repmat(y2, length(x), 1) );
xlabel('f2 (relatively LSF)');
