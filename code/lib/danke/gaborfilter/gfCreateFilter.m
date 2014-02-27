function f = gfCreateFilter(frequency, orientation, fsize, ftype)
%
% Create a normalized 2D Gabor filter in the spatial domain.
%
% f = gfCreateFilter(frequency, orientation, fsize)
%   frequency: spatial frequency of the filter
%   orientation: orientation of the filter
%   fsize: size of the filter
%   ftype: type of the filter
%
%   f: the Gabor filter returned
%
%   ftype can be 1,2,3,4.
%   1: default filter type.
%   2: the filter used in Dailey, Matthew N. and Cottrell, Garrison W.
%   (1999) Organization of Face and Object Recognition in Modular Neural
%   Networks. Neural Networks 12(7-8):1053-1074.
%   G(k,x) = exp(ikx)exp(-kkxx/(2pipi)
%   3: the filter used for reconstruction from magnitudes
%   4: the filter used in Dailey, Mattew N. and Cottrell, Garrison W.
%   (2002) EMPATH: A Neural Networks that Categorizes Facial Expressions
%
% -- Honghao Shan

if (nargin == 3)
    ftype = 1;
end;

% decide the height and the width of the filter
if (length(fsize) > 1)
    height = fsize(1);
    width = fsize(2);
else
    height = fsize;
    width = fsize;
end;

% get all the (x,y) pairs relative to the center of this filter
[X,Y] = meshgrid(ceil(-width/2):floor(width/2), ...
    ceil(-height/2):floor(height/2));

% calculate all the f(x,y) value
switch (ftype)
  case 1
    f = (frequency*frequency)/(pi) ...
        * exp(- frequency*frequency*(X.*X+Y.*Y) ...
              + sqrt(-1)*2*pi*frequency*(X*cos(orientation)+Y*sin(orientation)));
  case 2 %(matt dailey 1999)
    f=exp(i*frequency*(cos(orientation)*X+sin(orientation)*Y)).*exp(-frequency*frequency*(X.*X+Y.*Y)/2/pi/pi);

  case 3
   f = (frequency*frequency)/(pi*pi) ...
    * exp(- frequency*frequency*(X.*X+Y.*Y)/(2*pi*pi) ...
          + i*frequency*(X*cos(orientation)+Y*sin(orientation)));

  case 4 %matt dailey 2002, Marni's with a typo!
    k=pi*2^(-(frequency+2)/2);
    f = ...
        (k*k / (4*pi*pi))  ...                         (normalization)
        * exp(-(k*k) * (X.*X+Y.*Y) / (8*pi*pi)) ...  (Gaussian)
        .* exp(i * k * (X*cos(orientation)+Y*sin(orientation)) - exp(-2*pi*pi)); % (oscillatory)

  otherwise
    error('Unknown filter type: %d', ftype);
end;
