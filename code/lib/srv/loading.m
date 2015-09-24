function [M,indicesdeb2,indicesfin2,s2] = loading(A)


[nr,nc]=size(A);




p=60; 
ppm(1,:)=A(1,:);
Cov(1,:)=A(2,:);
Corr(1,:)=A(3,:);
Pv(1,:)=A(4,:);


M=max(Corr);
N1=max(Cov);
N2=min(Cov);
m=M/p;
colors=colormap(jet(p));
colors(1,:)=[0,0,0];


f=plot(ppm,Cov);
hold on

for j = 1:60
    
    ndeb=0;
    nfin=0;
    indicesdeb=[];
    indicesfin=[];
   
    for i = 1:nc-1
                
        
            if ( (abs(Corr(i))>=(j*m)) && (abs(Corr(i+1))<(j*m)) )
            
                nfin=nfin+1;
                indicesfin(nfin)=i;
            
            elseif ( (abs(Corr(i+1))>=(j*m)) && (abs(Corr(i))<(j*m)) )
            
                ndeb=ndeb+1;
                indicesdeb(ndeb)=i+1;
            end
        
    end
    

    sd=size(indicesdeb,2);
    sf=size(indicesfin,2);
    
    if ( sd == sf+1 )
        indicesfin=[indicesfin,nc];
    end
    
    if ( sd == sf-1 )
       indicesdeb=[1,indicesdeb];
    end
    
    s=size(indicesdeb,2);
   
        for k = 1:s
     
            f=plot(ppm(indicesdeb(k):indicesfin(k)),Cov(indicesdeb(k):indicesfin(k)),'LineWidth',1);
            set(f,'color',colors(j,:));
            hold on
        end
        
    
%    colorbar
    
end



    
    ndeb2=0;
    nfin2=0;
    indicesdeb2=[];
    indicesfin2=[];
   
   
    for i = 1:nc-1
                
        if (Pv(i+1)>Pv(i))
            nfin2=nfin2+1;
            indicesfin2(nfin2)=i;
            
        elseif (Pv(i+1)<Pv(i))
            ndeb2=ndeb2+1;
            indicesdeb2(ndeb2)=i;
        end
    end
   
    
    indicesdeb2=[1,indicesdeb2];
    indicesfin2=[indicesfin2,nc];
    
    
    s2=size(indicesdeb2,2);
    
   
        for k = 1:s2
            f=plot(ppm(indicesdeb2(k):indicesfin2(k)),Cov(indicesdeb2(k):indicesfin2(k)),'LineWidth',1);
            set(f,'color', [0.5,0.5,0.5]);
            hold on
        end
    
set(gca,'Xdir','reverse');
xlabel ('1H Chemical Shift (ppm)','Fontsize',12); 
ylabel ('OPLS coefficients','Fontsize',12);
set(gca,'FontName','Arial');
col = colorbar;
set(get(col,'ylabel'),'string','Correlation','Fontsize',12);
set(gca,'FontName','Arial');  
    
    
    
    
  
   






