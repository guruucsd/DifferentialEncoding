function imC = Polar2Im(imP,W,method)
%Polar2Im turns a polar image (imP) into a cartesian image (imC) of width W
%method can be: '*linear', '*cubic', '*spline', or '*nearest'.

imC = PolarToIm1(imP);
return;

W = max(size(imP));
method='*spline';

imP(isnan(imP))=0;
w = round(W/2);
xy = (1:W-w);
[M N P]= size(imP);
[x y] = meshgrid(xy,xy);
n = round(N/4);
rr = linspace(1,w,M);
W1 = w:-1:1;
PM = [2 1 3;1 2 3;2 1 3;1 2 3];
W2 = w+1:2*w;
nn = [1:n; n+1:2*n; 2*n+1:3*n; 3*n+1:N; ];
w1 = [W1;W2;W2;W1];
w2 = [W2;W2;W1;W1];
aa = linspace(0,90*pi/180,n);
r = sqrt(x.^2 + y.^2);
a = atan2(y,x);
imC= zeros(W,W,P);
for i=1:4 %turn each quarter into a cartesian image
imC(w1(i,:),w2(i,:),:)=permute(interp2(rr,aa,imP(:,nn(i,:))',r,a,method),PM(i,:));
end
imC(isnan(imC))=0;

function imR = PolarToIm1 (imP, rMin, rMax, Mr, Nr)
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
if ~exist('Mr','var'), Mr=size(imP,2); end;
if ~exist('Nr','var'), Nr=size(imP,1); end;


imR = zeros(Mr, Nr);
Om = (Mr+1)/2; % co-ordinates of the center of the image
On = (Nr+1)/2;
sx = (Mr-1)/2; % scale factors
sy = (Nr-1)/2;

[M N] = size(imP);

delR = (rMax - rMin)/(M-1);
delT = 2*pi/N;

dr = (rMax - rMin)/(M-1);
dth = 2*pi/N;

r=(rMin:dr:rMin+(M-1)*dr);
th=(0:dth:(N-1)*dth);
[r,th]=meshgrid(r,th); r=r'; th=th'
imR = PolarToIm2(imP, rMin, rMax, Mr, Nr);%interp2(imP, r, th); %interpolate (imR, xR, yR);






function imR = PolarToIm2 (imP, rMin, rMax, Mr, Nr)
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


imR = zeros(Mr, Nr);
Om = (Mr+1)/2; % co-ordinates of the center of the image
On = (Nr+1)/2;
sx = (Mr-1)/2; % scale factors
sy = (Nr-1)/2;

[M N] = size(imP);

delR = (rMax - rMin)/(M-1);
delT = 2*pi/N;

for xi = 1:Mr
for yi = 1:Nr
    x = (xi - Om)/sx;
    y = (yi - On)/sy;
    r = sqrt(x*x + y*y);
    if r >= rMin & r <= rMax
       t = atan2(y, x);
       if t < 0
           t = t + 2*pi;
       end

        ri = 1 + (r - rMin)/delR;
        ti = 1 + t/delT;
        rf = floor(ri);
        rc = ceil(ri);
        tf = floor(ti);
        tc = ceil(ti);
        if tc > N
            tc = tf;
        end
        if rf == rc & tc == tf
            imR (xi, yi) = imP (rc, tc);
        elseif rf == rc
            imR (xi, yi) = imP (rf, tf) + (ti - tf)*(imP (rf, tc) - imP (rf, tf));
        elseif tf == tc
            imR (xi, yi) = imP (rf, tf) + (ri - rf)*(imP (rc, tf) - imP (rf, tf));
        else
           A = [ rf tf rf*tf 1
                 rf tc rf*tc 1
                 rc tf rc*tf 1
                 rc tc rc*tc 1 ];
           z = [ imP(rf, tf)
                 imP(rf, tc)
                 imP(rc, tf)
                 imP(rc, tc) ];
           a = A\double(z);
           w = [ri ti ri*ti 1];
           imR (xi, yi) = w*a;
        end
    end
end
end

