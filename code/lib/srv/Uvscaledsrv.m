function [U,ET] = uvscaledsrv(A)
%uvscaling of a mtrix. The residual water area around is put to
%0.

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


[linf,lsup]=extractzeros(A);

U(:,lsup:linf)=0;