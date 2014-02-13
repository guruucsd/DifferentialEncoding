function V=vincentiles(x,m)
% VINCENTILES Compute m vincentiles for the data vector x
% Vincentiles suck.
x=sort(x);
n=length(x);
dims=size(x);
if dims(2)==1,
   x=x';
end
copyx=ones(m,1)*x;
vinx=reshape(copyx,n,m);
V=mean(vinx)';
