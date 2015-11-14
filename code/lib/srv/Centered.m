function C = centered(A)
%Centred Centre les variables d'une matrice.
%   Class support for input A:
%      float: double, single

[no,nv]=size(A);

s = sum(A);

for j= 1:nv
    m(j)=s(j)/no;
    A(:,j)=A(:,j)-m(j);
end

C=A;
