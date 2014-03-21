function k=Gausskernel(t,y,a)
% GAUSSKERNEL The Gaussian kernel density estimate.
% Syntax k=Gausskernel(t,y,a), where t are the time points, y is the 
% sorted data, and a is an optional multiplicative constant for the
% bandwidth parameter h.
if (nargin==2)
   c=.9;
elseif (nargin==3)
   c=a;
end
h = c*min(std(y),iqr(y)/1.349)/length(y)^.2;
k = mean(normpdf( (ones(length(t),1) * y' - t * ones(1,length(y)))' ,0,h))';
