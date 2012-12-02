function imR = mfe_pol2img(imP, rMin, rMax, Mr, Nr)
% POLARTOIM converts polar image to rectangular image. 
%
% V0.1 16 Dec, 2007 (Created) Prakash Manandhar, pmanandhar@umassd.edu
%
% This is the inverse of ImToPolar. imP is the polar image with M rows and
% N columns of data (double data between 0 and 1). M is the number of
% samples along the radius from rMin to rMax (which are between 0 and 1 and
% rMax > rMin). Mr and Nr are the number of pixels in the rectangular
% domain. The center of the image is assumed to be the origin for the polar
% co-ordinates, and half the width of the image corresponds to r = 1.
% Bilinear interpolation is performed for points not in the imP image and
% points not between rMin and rMax are rendered as zero. The output is a Mr
% x Nr grayscale image (with double values between 0.0 and 1.0).

if ~exist('rMin','var'), rMin=0; end;
if ~exist('rMax','var'), rMax=1; end;
if ~exist('Mr','var'), Mr=size(imP,1); end;
if ~exist('Nr','var'), Nr=size(imP,2); end;

[M N] = size(imP); % size of rectangular image 
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

warning off MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId
F = TriScatteredInterp(xP(:),yP(:),imP(:));
[X,Y] = meshgrid(1:N,1:M);
imR = reshape(F(X(:),Y(:)), [M N]);
return


[Mr Nr] = size(imP); % size of rectangular image 
xRc = (Mr+1)/2; % co-ordinates of the center of the image 
yRc = (Nr+1)/2; 
sx = (Mr-1)/2; % scale factors 
sy = (Nr-1)/2;

r=linspace(rMin,rMax,M); 
th=linspace(0,2*pi,N);%:dth:(N-1)*dth)'; 
[th,r]=meshgrid(th,r);  
x=r.*cos(th); 
y=r.*sin(th); 
xP = x(end:-1:1,:)*sx + xRc; 
yP = y(end:-1:1,:)*sy + yRc; 

F = TriScatteredInterp(yP(:),xP(:),imP(:));
[X,Y] = meshgrid(1:M,1:N);
imR = reshape(F(Y(:),X(:)), [N M])';
