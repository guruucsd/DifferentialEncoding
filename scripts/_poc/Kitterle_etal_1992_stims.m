
%%Kitterle

minmax = [0 1];

x = linspace(-pi, pi, 31);

f0 = 7.5*(2*pi);
f2 = 3.28 * (2*pi);

y2 = mean(minmax) + (diff(minmax)/2)*sin((f2/(2*pi)) * x);

c3 = mean(minmax) + (diff(minmax)/2) * sin((f0/(2*pi)) * x  + 0.3);
b3 = round(mean(minmax) + (diff(minmax)/2) * sin((f0/(2*pi)) * x + 0.75));

figure; 

subplot(2,2,1);
imshow(repmat(y2, length(x), 1));
xlabel(sprintf('"Are the bars wide or narrow?"\n(LSF information)'));

subplot(2,2,2);
imshow(repmat(y2, length(x), 1));
xlabel(sprintf('"Are the bars sharp or fuzzy?"\n(HSF information)'));

subplot(2,2,3);
imshow(repmat(c3, length(x), 1));

subplot(2,2,4);
imshow(repmat(b3, length(x), 1));
