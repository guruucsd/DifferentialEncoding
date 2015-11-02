function [Xclusterf,indicesdebf,indicesfinf,nct]=ClusterfinalSRV(Xcluster2,Xcluster,fincluster2,debcluster2,indicesfin,indicesdeb,s1,s3);

Xclusterf=Xcluster(:,1:debcluster2(1)-1);
indicesdebf=indicesdeb(1:debcluster2(1)-1);
indicesfinf=indicesfin(1:debcluster2(1)-1);


for j=1:s3-1
    Xclusterf=[Xclusterf,Xcluster2(:,j),Xcluster(:,fincluster2(j)+1:debcluster2(j+1)-1)];
    indicesdebf=[indicesdebf,indicesdeb(debcluster2(j)),indicesdeb(fincluster2(j)+1:debcluster2(j+1)-1)];
    indicesfinf=[indicesfinf,indicesfin(fincluster2(j)+1),indicesfin(fincluster2(j)+1:debcluster2(j+1)-1)];
end

Xclusterf=[Xclusterf,Xcluster2(:,s3)];
Xclusterf=[Xclusterf,Xcluster(:,fincluster2(s3)+1:s1)];
indicesdebf=[indicesdebf,indicesdeb(debcluster2(s3)),indicesdeb(fincluster2(s3)+1:s1)];
indicesfinf=[indicesfinf,indicesfin(fincluster2(s3)+1),indicesfin(fincluster2(s3)+1:s1)];
       
[nrt,nct]=size(Xclusterf);

for j=1:nct-1
    if (indicesdebf(j+1)<indicesfinf(j))
        indicesfinf(j)=indicesdebf(j+1)-1;
    end
end