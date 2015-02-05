function [b,bint,l,ang,r] = rmaregress(x,y,s,alpha)
%RMAREGRESS Ranged Major Axis Regression.
%   Model II regression should be used when the two variables in the
%   regression equation are random and subject to error, i.e. not 
%   controlled by the researcher. Model I regression using ordinary least 
%   squares underestimates the slope of the linear relationship between the
%   variables when they both contain error. According to Sokal and Rohlf 
%   (1995), the subject of Model II regression is one on which research and
%   controversy are continuing and definitive recommendations are difficult
%   to make.
%
%   RMAREGRESS is a Model II procedure. Ranged major axis regression is 
%   only described in Legendre and Legendre (1998:511-512). The slope 
%   estimator has several desirable properties when the variables x and y 
%   are not expressed in the same units or when the error variances on the
%   two axes differ. The slope estimator scales proportionally to the units
%   of the two variables: the position of the regression line in the 
%   scatter of points remains the same irrespective of any linear change of
%   scale of the variables. The estimator is sensitive to the covariance of
%   the variables. The procedure should not be used in the presence of 
%   outliers because they cause important changes to the estimates of the 
%   ranges of the variables.
%
%   Ranged major axis regression is major axis regression (MAREGRESS) 
%   computed from ranged data.
%
%   [B,BINT,L,ANG,R] = RMAREGRESS(X,Y,ALPHA) returns the vector B of 
%   regression coefficients in the linear Model II, a matrix BINT of the
%   given confidence intervals for B, the L eigenvalues of the axes, the
%   angle in degrees of the confidence bounds, and R the minimum and 
%   maximum x and y ratio-scales.
%
%   RMAREGRESS treats NaNs in X or Y as missing values, and removes them.
%
%   Syntax: [b,bint,l,ang,r] = rmaregress(x,y,s,alpha)
%
%   The s input argument takes the value of 1 for variables whose variation
%   is expressed relative to an arbitrary zero (interval-scale variables, 
%   e.g. temperature in °C), and 2 for variables whose variation is 
%   expressed relative to a true zero value (ratio-scale or relative-scale
%   variables, e.g. species abundances, or temperature expressed in °K), 
%   the recommended formula for ranging assumes a minimum value of 0.
%
%   Example. From the Box 14.12 (California fish cabezon [Scorpaenichthys 
%   marmoratus]) of Sokal and Rohlf (1995). The data are:
%
%   x=[14,17,24,25,27,33,34,37,40,41,42];
%   y=[61,37,65,69,54,93,87,89,100,90,97];
%
%   s=[2,2];
%
%   Calling on Matlab the function: 
%                [b,bint,l,ang,r] = rmaregress(x,y,s)
%
%   Answer is:
%
%   b =
%      13.1797    2.0869
%
%   bint =
%     -18.4757   35.2532
%       1.3599    3.1294
%
%   l =
%       0.0893    0.0055
%
%   ang =
%      64.3972
%
%   r =
%      0    42
%      0   100
%   
%   Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.edu.mx
%
%   Copyright (C)  June 10, 2010. 
%
%   To cite this file, this would be an appropriate format:
%   Trujillo-Ortiz, A. and R. Hernandez-Walls. (2010). rmaregress: 
%      Ranged Major Axis Regression. A MATLAB file. [WWW document]. URL
%      http://www.mathworks.com/matlabcentral/fileexchange/27917-rmaregress
%    
%   References:
%   Legendre, P. and Legendre, L. (1998), Numerical ecology. 2nd English 
%              edition. Amsterdam:Elsevier Science BV. 
%   Sokal, R. R. and Rohlf, F. J. (1995), Biometry. The principles and
%              practice of the statistics in biologicalreserach. 3rd. ed.
%              New-York:W.H.,Freeman. [Sections 14.13 and 15.7] 
%

if  nargin < 3
    error('rmaregress:TooFewInputs', ...
          'RMAREGRESS requires at least three input arguments.');
elseif nargin == 3
    alpha = 0.05;
end

x = x(:); y = y(:);

% Check that matrix (X) and rigth hand side (Y) have compatible dimensions
[n,ncolx] = size(x);
if ~isvector(y)
    error('rmaregress:InvalidData', 'Y must be a vector.');
elseif numel(y) ~= n
    error('rmaregress:InvalidData', ...
          'The number of rows in Y must equal the number of rows in X.');
end

% Remove missing values, if any
wasnan = (isnan(y) | any(isnan(x),2));
havenans = any(wasnan);
if havenans
   y(wasnan) = [];
   x(wasnan,:) = [];
   n = length(y);
end

if s(1) == 1;
    x1 = min(x);
else s(1) == 2;
    x1 = 0.0;
end
x2 = max(x);
if s(2) == 1;
    y1 = min(y);
else s(2) == 2;
    y1 = 0.0;
end
y2 = max(y);

r = [x1,x2;y1,y2];

xr=[];yr=[];
for i = 1:n;
    xrr = (x(i)-x1)./(x2-x1);
    yrr = (y(i)-y1)./(y2-y1);
    xr = [xr;xrr];yr = [yr;yrr];
end

x = xr;y = yr;

S = cov(x,y);
b1r= ((S(2,2)-S(1,1))+sqrt(((S(2,2)-S(1,1))^2)+4*(S(1,2)^2)))/(2*S(1,2)); %slope
b1 = b1r*(y2-y1)/(x2-x1);
a = ((mean(y)*(y2-y1))+y1)-b1*((mean(x)*(x2-x1))+x1); %intercept
b = [a,b1];
D = sqrt((S(1,1)+S(2,2))^2-4*((S(1,1)*S(2,2))-S(1,2)^2));
l1 = (S(1,1)+S(2,2)+D)/2; %eigenvalue of major (principal) axis
l2 = (S(1,1)+S(2,2)-D)/2; %eigenvalue of minor axis
H = (finv(1-alpha,1,n-2))/(((l1/l2)+(l2/l1)-2)*(n-2));
A = sqrt(H/(1-H));
Li = (b1r-A)/(1+b1r*A)*(y2-y1)/(x2-x1); %confidence lower limit of slope
Ls = (b1r+A)/(1-b1r*A)*(y2-y1)/(x2-x1); %confidence upper limit of slope
l = [l1,l2];
ai = ((mean(y)*(y2-y1))+y1)-Ls*((mean(x)*(x2-x1))+x1); %confidence lower limit of intercept
as = ((mean(y)*(y2-y1))+y1)-Li*((mean(x)*(x2-x1))+x1); %confidence upper limit of intercept
bint = [ai,as;Li,Ls];
ang = atand(b1); %angle in degrees

return,