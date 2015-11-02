function [debcluster2,fincluster2]=agregationSRV(Clustercorrelation,correlationthreshold,s1);


n2=0;
balises=[];

for j=1:s1-1
    if(Clustercorrelation(j)>correlationthreshold)
        n2=n2+1;
        balises(n2)=j;
    end
end


s2=size(balises,2);


choixbalises=[];
for k=2:s2-1
    if((balises(k)+1)==(balises(k+1)))
        choixbalises(k)=1;
    elseif((balises(k)+1)~=(balises(k+1)))
        choixbalises(k)=0;
    end
end

if (balises(1)+1== balises(2))
    choixbalises(1)=1;
else choixbalises(1)=0;
end

if (balises(s2)-1== balises(s2-1))
    choixbalises(s2)=1;
else choixbalises(s2)=0;
end

for j=2:s2-1
    if ((choixbalises(j-1)==choixbalises(j)) &&(choixbalises(j+1)==choixbalises(j)))
        choixbalises(j)=0;
    end
end

debcluster2=[];
fincluster2=[];
ndeb2=0;
nfin2=0;
for k=2:s2-1
    if (choixbalises(k)==0 && choixbalises(k-1)~=1)
        ndeb2=ndeb2+1;
        nfin2=nfin2+1;
        debcluster2(ndeb2)=balises(k);
        fincluster2(nfin2)=balises(k);
        
    elseif (choixbalises(k)>choixbalises(k-1))
        ndeb2=ndeb2+1;
        debcluster2(ndeb2)=balises(k);
        
    elseif (choixbalises(k)==0 && choixbalises(k-1)==1)
        nfin2=nfin2+1;
        fincluster2(nfin2)=balises(k);
    end
end    

if(choixbalises(s2-1)==1)
    nfin2=nfin2+1;
    fincluster2(nfin2)=balises(s2);
else 
    nfin2=nfin2+1;
    ndeb2=ndeb2+1;
    fincluster2(nfin2)=balises(s2);
    debcluster2(ndeb2)=balises(s2);
end

if(choixbalises(1)==1)
    debcluster2=[balises(1),debcluster2];
else 
    debcluster2=[balises(1),debcluster2];
    fincluster2=[balises(1),fincluster2];
end