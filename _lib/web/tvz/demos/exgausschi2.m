function [x,s]=exgausschi2(X,t,p)
% EXGAUSSCHI2 Chi2 statistic for exgaussian fit to data t.
% Syntax [x,p]=exgausschi2(t,X,p), for data t, parameters X, and percentiles p.
pts=[10:10:90];
if nargin>2,
   pts =p;
end
y1=prctile(t,pts)';
E1=[0;exgausscdf(y1,X)];
E2=[E1(2:length(pts)+1);1];
E=reshape(length(t)*(E2-E1),length(pts)+1,1);
O=reshape(length(t)*([pts,100]-[0,pts])/100,length(pts)+1,1);
x=(O-E)'*((O-E)./E);
s=1-chi2cdf(x,length(pts)-length(X));
