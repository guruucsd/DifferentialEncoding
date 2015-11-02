function [U,ET] = uvscaled(A)
%uvscaled Centre et réduit les variables d'une matrice.
%   Class support for input A:
%      float: double, single

[NO,NV]=size(A);
s = sum(A);
m = s/NO;

for j= 1:NV
    ET(j)=std(A(:,j));
end

for j= 1:NV
    M=m(j)*ones(NO,1);
    U(:,j)=(A(:,j)-M)/ET(j);
end