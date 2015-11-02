function [K] = signalSRV(A,liminf,limsup,indicesdebf,indicesfinf,nct)

[nr,nc]=size(A);

N=A;

N(:,1:liminf-1)=[];
N(:,limsup-(liminf-1)+1:nc-(liminf-1))=[];

[nrl,ncl]=size(N);

   Signal=[];

for i=1:nr

    mu=[];
    sigma=[];

    for j=1:ncl
    
        [mu(j),sigma(j)]=normfit(A(:,j));
    
    end

    mu=mu';
    sigma=sigma';

    muN=sum(mu)/(limsup-liminf+1);
    sigmaN=sum(sigma)/(limsup-liminf+1);

    Treshold=muN+1.96*sigmaN;

    for j=1:nc
    
        if ( A(i,j) >= Treshold )
        
        Signal(i,j)=1;
        else Signal(i,j)=0;
        end
    end
end

Moyenne=sum(Signal)/nr;

SignalTOT=[];

for j=1:nc
    
    if (Moyenne(j)>=0.5)
        SignalTOT(j)=1;
    else SignalTOT(j)=0;
    end
end

I=sum(SignalTOT);

SignalCluster=[];

for i=1:indicesdebf(1)-1
    SignalCluster(i)=0;
end

for i=1:nct-1
    for j=indicesfinf(i)+1:indicesdebf(i+1)-1
        SignalCluster(j)=0;
    end
end

for i=1:nct
    for j=indicesdebf(i):indicesfinf(i)
        SignalCluster(j)=1;
    end
    
end

for i=indicesfinf(nct)+1:nc
    SignalCluster(i)=0;
end

K=zeros(2,2);

for i=1:nc
    if(SignalCluster(i)==1 && SignalTOT(i)==1)
        K(2,2)=K(2,2)+1;
    end
    
    if(SignalCluster(i)==1 && SignalTOT(i)==0)
        K(1,2)=K(1,2)+1;
    end
    
    if(SignalCluster(i)==0 && SignalTOT(i)==1)
        K(2,1)=K(2,1)+1;
    end
    
    if(SignalCluster(i)==0 && SignalTOT(i)==0)
        K(1,1)=K(1,1)+1;
    end
    
end

signalP=K(2,2)/I;
signalN=K(1,1)/(nc-I);

K=K/nc;

S=[signalN,signalP];

K=[K;S];

        
        


        





