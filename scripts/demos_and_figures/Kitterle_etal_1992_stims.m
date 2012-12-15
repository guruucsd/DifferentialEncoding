% Demo figure of our Kitterle et al (1992) stimuli

minmax = [0 1];

x = linspace(-pi, pi, 31);

f0 = 7.5*(2*pi);
f2 = 3.28 * (2*pi);

y2 = mean(minmax) + (diff(minmax)/2)*sin((f2/(2*pi)) * x);
b2 = round(mean(minmax) + (diff(minmax)/2)*sin((f2/(2*pi)) * x) - 0.075);

c3 = mean(minmax) + (diff(minmax)/2) * sin((f0/(2*pi)) * x  + 0.3);
b3 = round(mean(minmax) + (diff(minmax)/2) * sin((f0/(2*pi)) * x + 0.75));

figure; 
set(gcf, 'position', [360 189 500 500])

subplot(2,2,1);
imshow(repmat(y2, length(x), 1));
title('sine wave gratings', 'FontSize', 14) 
ylabel('lower frequency', 'FontSize', 14)
%xlabel(sprintf('"Are the bars wide or narrow?"\n(LSF information)'));

subplot(2,2,2);
imshow(repmat(b2, length(x), 1));
title('square wave gratings', 'FontSize', 14) 
%xlabel(sprintf('"Are the bars sharp or fuzzy?"\n(HSF information)'));

subplot(2,2,3);
imshow(repmat(c3, length(x), 1));
ylabel('higher frequency', 'FontSize', 14)

subplot(2,2,4);
imshow(repmat(b3, length(x), 1));
