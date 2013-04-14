function [x,s]=chi2(t,func,X,p)
% Chi2 statistic for fit of model func with parameters X to data t.
% Syntax [x,p]=chi2(t,func,X,p), for data t, parameters X, and percentiles p 
% (optional).
pts=[10:10:90];
if nargin>3,
   pts =p;
end
y1=prctile(t,pts)';
E1=[0;feval(func,y1,X)];
E2=[E1(2:length(pts)+1);1];
E=reshape(length(t)*(E2-E1),length(pts)+1,1);
O=reshape(length(t)*([pts,100]-[0,pts])/100,length(pts)+1,1);
x=(O-E)'*((O-E)./E);
s=1-chi2cdf(x,length(pts)-length(X));
