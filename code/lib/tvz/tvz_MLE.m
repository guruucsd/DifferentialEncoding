function F=MLE(p,func,t,byn)
% MLE Objective function for maximizing likelihood
% Syntax F=MLE(p,func,t,byn), where p is a vector of parameters to be
% passed to the function func, and t is the data vector.  The variable
% byn, if present, signals that the likelihood should by computed only
% for the unique values in t.
% Call as, e.g.,
% X=fminsearch('MLE',[200,7,.01],optimset('MaxFunEvals',500),'gammapdf',t)
warning off
if (nargin==4),
   [m s n]=tabulate_stats(t,t);
   k=log(feval(func,n(:,1),p));
   k=reshape(k,length(k),1);
   F=-sum(n(:,1).*k);
elseif (nargin==3),
   F=-sum(log(feval(func,t,p)));
end
