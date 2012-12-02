function imP = mfe_img2pol (imR, rMin, rMax, M, N)
% IMTOPOLAR converts rectangular image to polar form. The output image is 
% an MxN image with M points along the r axis and N points along the theta
% axis. The origin of the image is assumed to be at the center of the given
% image. The image is assumed to be grayscale.
% Bilinear interpolation is used to interpolate between points not exactly
% in the image.
%
% rMin and rMax should be between 0 and 1 and rMin < rMax. r = 0 is the
% center of the image and r = 1 is half the width or height of the image.
%
% V0.1 7 Dec 2007 (Created), Prakash Manandhar pmanandhar@umassd.edu
if ~exist('rMin','var'), rMin=0; end;
if ~exist('rMax','var'), rMax=1; end;
if ~exist('M','var'), M=size(imR,1); end;
if ~exist('N','var'), N=size(imR,2); end;


[Mr Nr] = size(imR); % size of rectangular image 
xRc = (Nr+1)/2; % co-ordinates of the center of the image 
yRc = (Mr+1)/2; 
sx = (Nr-1)/2; % scale factors 
sy = (Mr-1)/2;

r=linspace(rMax,rMin,M); 
th=linspace(0+atan(2/M)/2, 2*pi-atan(2/M)/2,N);%:dth:(N-1)*dth)'; 
[th,r]=meshgrid(th,r);%r,th); 
x=r.*cos(th); 
y=r.*sin(th); 
xP = x*sx + xRc; 
yP = y*sy + yRc; 
imP = interp2(imR, xP, yP); %interpolate (imR, xR, yR);
keyboard
th
