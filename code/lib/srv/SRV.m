
function [Data,Xclusterf,Ibegin,Iend,Ncl] = SRV(X,Y,singletsize,resolution,correlationthreshold,significancethreshold,ppm,NF)

%Statistical Recoupling of Variables.
%input: data matrix X, class matrix Y, size of a typical aromatic singlet, bucketing resolution, correlation threshold for cluster aggregation, significance threshold for significance testing, vector containing chemical shift values, number of factors for OPLS loading computation
%output: Data matrix containing in rows chemical shift values-loading value-correlation between superclusters and class information Y matrix-pvalue, SRV cluster matrix and supercluster borders: Ibegin and Iend.

warning("off");


[nr,nc]=size(X);
Landscape=zeros(1,nc-1);

Xct=Centered(X);
Xuv=Uvscaledsrv(X);
Yct=Centered(Y);


%Step1: Calculation of the covariance/correlation profile between consecutive variables

C=[];
C1=[];

  for j=1:nc-1
      C=cov(Xct(:,j),Xct(:,j+1));
      C1=corrcoefNaN(Xuv(:,j),Xuv(:,j+1));
%      Landscape(j)=C(1,2)/abs(C1(1,2));
% adaptation to octave
      Landscape(j)=C/abs(C1);
  end

%Identification of the residual water area
  
  [linf,lsup]=extractzeros(X);
  
  Landscape(lsup:linf)=0;
  
%Step 2: Identification of spectral SRV clusters. Scan of the profile for the identification of local minima starting and ending variables of each cluster are stored in indicesdeb and indicesfin according to the covariance/correlation profile.
  
  indicesdeb=[];
  indicesfin=[];
  ndeb=1;
  nfin=0;
  
  indicesdeb(ndeb)=1;
  for j=2:nc-2
  
      if (Landscape(j)<Landscape(j-1) && Landscape(j)<Landscape(j+1))
          nfin=nfin+1;
          indicesfin(nfin)=j;
          ndeb=ndeb+1;
          indicesdeb(ndeb)=j+1;   
      end  
  end
  
  if(indicesfin(nfin)~=nc)
      indicesfin=[indicesfin,nc];
  end

% Clusters with limited number of variables with respect to the singletsize parameter are discarded.
  
  indices=indicesfin-indicesdeb+1;

  si=size(indices,2);

  destruction=[];
  ndestruction=0;
  
  limit=floor(singletsize/(resolution));

  
  for j=1:si
      if(indices(j)<limit)
          ndestruction=ndestruction+1;
          destruction(ndestruction)=j;
      end
  end
  
  sd=size(destruction,2);
  
      for l=1:sd
          indicesdeb(destruction(l))=[];
          indicesfin(destruction(l))=[];
          destruction=destruction-1;
      end
  
% Each cluster contains the mean of the variables within its borders.

  Xcluster=[];
  s1=size(indicesdeb,2);
  
  for j=1:s1
      Temp=zeros(nr,1);
      for k=indicesdeb(j):indicesfin(j)
          Temp=Temp+X(:,k);
      end
      Xcluster(:,j)=Temp/(indicesfin(j)-indicesdeb(j)+1);
  end
  
  
% Step 3: Identification of NMR variables. Correlation of neighboring clusters stored in Clustercorrelation. Identification of highly correlated clusters.
  
  Clustercorrelation=zeros(1,s1-1);
  for j=1:s1-1
      %C2=corrcoef(Xcluster(:,j),Xcluster(:,j+1));
      %Clustercorrelation(j)=abs(C2(1,2));
      % adaptation to octave
      C2=corrcoefNaN(Xcluster(:,j),Xcluster(:,j+1));
      Clustercorrelation(j)=abs(C2);
  end
 
  
  [debcluster2,fincluster2]=agregationSRV(Clustercorrelation,correlationthreshold,s1);
  
  
  s3=size(debcluster2,2);
  
  Xcluster2=[];
  
  for j=1:s3
      Temp2=zeros(nr,1);
      for k=debcluster2(j):fincluster2(j)+1
          Temp2=Temp2+Xcluster(:,k);
      end
      Xcluster2(:,j)=Temp2/(fincluster2(j)+1-debcluster2(j)+1);
  end

%NB: it is possible to work with other parameters such as the integration of the signal instead of the signal mean in each cluster.
 
  
  Xclusterf=[];
  Ibegin=[];
  Iend=[];
  
  [Xclusterf,Ibegin,Iend,Ncl]=ClusterfinalSRV(Xcluster2,Xcluster,fincluster2,debcluster2,indicesfin,indicesdeb,s1,s3);
  
 
% Step 4: Evaluation of pvalues and multiple test correction

%Analysis of variance by the one-way anova function of matlab modified to remove all printing options. Pvalue calculations can be performed by other approaches by changing the following 4 command lines.
  
    Pvalue=[];
    for j=1:Ncl
    Pvalue(j)=anovaSRV(Xclusterf(:,j),Y);
    end

%Computation of the Benjamini-Yekutieli correction on the Ncl-1 clusters (a cluster corresponds to the residual water signal and is removed before analysis). Other multiple test correction can be used.

  Pfinal=[];


  [Pfinal]=PBYcalculation_maxk_checked(Pvalue,significancethreshold,Ncl,nc,Ibegin,Iend);

%measurement of the correlation of the clusters/superclusters/residualvariables with the Y matrix.
  
  [Correlation]=correlationSRV(Xuv,Xclusterf,nc,Ncl,Ibegin,Iend,Yct);
  

%representationcluster(ppm,X(1,:),indicesdebf,indicesfinf);
  
  Covariance=[];
  
  [T,To,W,C,Xdef] = oplsSRV(Xct,Yct,NF);
  
  Covariance=W(:,NF);
  Covariance=Covariance';
  
  
  Data=[ppm;Covariance;Correlation;Pfinal];

  [X1,X2] = vectcolsign(Covariance,Pfinal);
  %[Fig] = loadingfig(ppm,X1,X2,Correlation);
  % adaptation to octave
  [Fig] = loading(Data);

% Step 5 can be performed with the orstocsy function














    