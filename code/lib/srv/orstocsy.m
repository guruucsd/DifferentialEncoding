function [R,Correlationtable] = orstocsy(A,Y,NF,correlation,Deb,Fin,ppm)

[no,nv]=size(A);

Act=Centered(A);
Yct=Centered(Y);

[T,To,W,C,Adef] = oplsSRV(Act,Yct,NF);

AdefUV=Uvscaled(Adef);

B=[];
B=1/(no-1)*AdefUV'*AdefUV;

P=[];

for i=1:nv
   for j=1:nv
	%[c,p]=corrcoef(AdefUV(:,i),AdefUV(:,j));
	% adaptation to octave
        [c,p]=corrcoefNaN(AdefUV(:,i),AdefUV(:,j));
        %P(i,j)=p(1,2);
	P(i,j)=p;
     end
end

significance=0.05/(floor(nv*nv/2)+1);

for i=1:nv
    for j=1:nv
        if( (abs(B(i,j))<correlation) || (P(i,j)>significance) )
            B(i,j)=0;
        end
    end
end

for i=1:nv
    I(i)=nv+1-i;
end

contour(I,I,B,40);
%adaptation to octave
set(gca,'Ydir','reverse');
hold on
xlabel ('SRV Clusters','Fontsize',12); 
ylabel ('SRV Clusters','Fontsize',12);
set(gca,'FontName','Arial');
hold on
col = colorbar;
set(get(col,'ylabel'),'string','Correlation','Fontsize',12);
set(gca,'FontName','Arial');

R=B;

n=0;
for i=1:nv
    for j=1:nv
        if(R(i,j)~=0)
            n=n+1;
        end
    end
end

n2=n;

n=n/(nv*nv);

n3=(n2-nv)/2;

Correlationtable=zeros(7,n3);
n1=0;

for i=1:nv
    for j=1:nv
        if(R(i,j)~=0 && i<j)
            n1=n1+1;
            Correlationtable(1,n1)=nv+1-i;
            Correlationtable(2,n1)=nv+1-j;
            Correlationtable(3,n1)=ppm(Deb(i));
            Correlationtable(4,n1)=ppm(Fin(i));
            Correlationtable(5,n1)=ppm(Deb(j));
            Correlationtable(6,n1)=ppm(Fin(j));
            Correlationtable(7,n1)=B(i,j);
        end
    end
end



        
        
