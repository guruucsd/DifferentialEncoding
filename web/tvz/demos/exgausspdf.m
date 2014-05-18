function k=exgausspdf(t,p)
% EXGAUSSPDF The ex-Gaussian pdf
% Syntax k=exgauss(t,p)
mu=p(1);
sigma=p(2);
tau=p(3);
k=exp(-t./tau + mu./tau + sigma.^2./2./tau.^2).*normcdf((t-mu-sigma.^2./tau)./sigma)./tau;
k(k==Inf)=zeros(length(k(k==Inf)),1);
if tau<0 | sigma<0,
   k=zeros(length(k),1);
end   
