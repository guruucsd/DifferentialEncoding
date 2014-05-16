function [k,s]=hazard(t,y,a)
% HAZARD The Epanechnikov hazard function estimator.
% Syntax [k,s]=hazard(t,y,a)
% The column vector t is the points for which the hazard function
% is to be estimated.  The column vector y is the ordered data.
% The constant a determines the degree of smoothing.  If output
% argument s is specified, the estimated standard error of the
% hazard estimate k will be returned.
warning off
if (nargin==2)
   c=.3;
elseif (nargin==3)
   c=a;
end
n=length(y);
h = c*min(std(y),iqr(y)/1.349)/n^.2;
fhat = mean(epanech(((ones(length(t),1)*y')-(t*ones(1,n)))'/h))'/h;
Fhat=mean(Iepanech(-((ones(length(t),1)*y')-(t*ones(1,n)))'/h))';
k=fhat./(1-Fhat);
if (nargout==2)
    int=.2683281571;
    s=sqrt(int*k.^2./fhat/n/h);
end
