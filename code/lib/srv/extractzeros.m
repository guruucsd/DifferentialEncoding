function [linf,lsup]=extractzeros(A)

a=1;
b=1;
c=2;
B=[a,b,c];
lsup=1;
[nr,nc]=size(A);
#while (any(B))
while (any(B) && lsup<nc+1)
        a=A(1,lsup);
        b=A(2,lsup);
        c=a-b;
        lsup=lsup+1;
        B=[a,b,c];
end
lsup=lsup-1;

d=1;
e=1;
f=1;
C=[d,e,f];
linf=nc;
#while any(C)
while (any(C) && linf>0)
        d=A(1,linf);
        e=A(2,linf);
        f=d-e;
        linf=linf-1;
        C=[d,e,f];
end
linf=linf+1;

