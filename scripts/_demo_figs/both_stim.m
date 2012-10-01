clear all; close all;

%% Christman
x = (-pi):0.05:8*pi;

y1 = 0.5+0.5*sin(x/4);
y2 = 0.5+0.5*sin(x/2);

y3 = 0.5+0.5*sin(x/1);

y4 = 0.5+0.5*sin(x/0.5);
y5 = 0.5+0.5*sin(x/0.25);

figure;

subplot(2,3,1);
imshow( repmat( (y1+y2)/2, length(x), 1) );
xlabel('f0+f1');

subplot(2,3,2);
imshow( repmat( (y1+y2+y3)/3, length(x), 1) );
xlabel('f0+f1+f2');

subplot(2,3,3);
imshow( repmat(y3, length(x), 1) );
xlabel('f2 (relatively HSF)');


subplot(2,3,4);
imshow( repmat((y3+y4+y5)/3, length(x), 1) );
xlabel('f3+f4');

subplot(2,3,5);
imshow( repmat((y4+y5)/2, length(x), 1) );
xlabel('f2+f3+f4');

subplot(2,3,6);
imshow( repmat(y3, length(x), 1) );
xlabel('f2 (relatively LSF)');

%%Kitterle

%b2 = round(0.5+0.5*sin((x+0.5)/2));
c3 = 0.5+0.5*sin((x+0.2)*3/2);
b3 = round(0.5+0.5*sin((x+0.5)*3/2));

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
