function Correlation=correlationSRV(Xuv,Xclusterf,nc,nct,indicesdebf,indicesfinf,Y);

CorrelationB=[];
for j=1:nc
    %ZB=corrcoef(Xuv(:,j),Y);
ZB=corrcoefNaN(Xuv(:,j),Y);
    CorrelationB(j)=abs(ZB);
end

Xclusterfuv=Uvscaled(Xclusterf);
CorrelationC=[];
for j=1:nct
    %ZC=corrcoef(Xclusterfuv(:,j),Y);
ZC=corrcoefNaN(Xclusterfuv(:,j),Y);
    CorrelationC(j)=abs(ZC);
end

Correlation=zeros(1,nc);
for i=1:indicesdebf(1)-1
    Correlation(i)=CorrelationB(i);
end

for i=1:nct-1
    for j=indicesfinf(i)+1:indicesdebf(i+1)-1
        Correlation(i)=CorrelationB(i);
    end
end

for i=1:nct
    for j=indicesdebf(i):indicesfinf(i)
        Correlation(j)=CorrelationC(i);
    end
end

for i=indicesfinf(nct)+1:nc
    Correlation(i)=CorrelationB(i);
end

