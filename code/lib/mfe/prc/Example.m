% Polar/Rectangular Conversion 
% V0.1 16 Dec 2007 (Created) Prakash Manandhar, pmanandhar@umassd.edu
im = rgb2gray(imread('TestIm.PNG'));
im = double(im)/255.0;
im=padarray(im,[0 9]);
figure(1); 
subplot(1,3,1); imshow(im);

imP = mfe_img2pol(im);
subplot(1,3,2); imshow(imP); axis on;
xlabel('theta'); set(gca,'xtick',[1 size(imP,2)/2 size(imP,2)], 'xticklabel',{'-pi' '0' 'pi'}); 
ylabel('radius'); set(gca, 'ytick', [0]);

imR = mfe_pol2img(imP);
subplot(1,3,3); imshow(imR);

%rMin = 0.25; rMax = 0.8;

%im2 = imread('TestIm2.jpg');
%figure(4); imshow(im2);
%imR2 = PolarToIm(im2, rMin, rMax, 300, 300);
%figure(5); imshow(imR2, [0 255]);