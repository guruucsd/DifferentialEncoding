function s=hazarderror(t,y,n)
% HAZARDERROR Estimate a standard error of the hazard function
% with n bootstrapped samples
% Syntax s=hazarderror(t,y,n)
% Note that if zeros are problematic anywhere in the vector t, this
% routine will not work.
if (nargin==2)
   n=1000;
end
for i=1:n,
    yb = sort(y([fix(rand(length(y),1)*length(y)) + 1]));
    h(1:length(t),i)=hazard(t,yb);
end
s=std(h')';
