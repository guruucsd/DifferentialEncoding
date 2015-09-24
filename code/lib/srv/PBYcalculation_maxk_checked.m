function [Pfinal] = PBYcalculation_maxk_checked(P,significancethreshold,nct,nc,indicesdebf,indicesfinf)
  
k = size(P,2);
PBY = ones(k,1);
 
[N,I]=sort(P);
a = 1;
n = 1:k;
q = sum(1./n);
 
for j=k:-1:1
    NBY(j,1) = min(a,N(1,j)*k*q/j);
    a = NBY(j,1);
end

PBY(I)=NBY;

for i = 1:nct
    
    if (PBY(i)<significancethreshold)
        PBY(i)=2;
    
    elseif (PBY(i)>=significancethreshold)
        PBY(i)=1;
    end
    
end



%Representaion of the final p-value vector for the initial nc variables
Pfinal=zeros(1,nc);

for i=1:indicesdebf(1)-1
    Pfinal(i)=1;
end

for i=1:nct-1
    for j=indicesfinf(i)+1:indicesdebf(i+1)-1
        Pfinal(j)=1;
    end
end

for i=1:nct
    if (PBY(i)==2)
        for j=indicesdebf(i):indicesfinf(i)
            Pfinal(j)=2;
        end
    else
        for j=indicesdebf(i):indicesfinf(i)
            Pfinal(j)=1;
        end
    end
    
end

for i=indicesfinf(nct)+1:nc
    Pfinal(i)=1;
end

