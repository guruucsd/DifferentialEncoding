function [Con, hpl, mu] = de_connector(model)
%[Con, mu] = de_connector(model)
%
% Creates a connectivity matrix for the given model
%
% Inputs:
% model : see de_model for details
%
% Outputs:
% Con   : connectivity matrix
  
  switch (length(model.nInput))
    case 1, [Con, hpl, mu] = de_connector1D( prod(model.nInput), ...
                                  model.nHidden,...
                                  model.nConns,...
                                  model.sigma,...
                                  model.ac.debug);
    case 2, [Con, hpl, mu] = de_connector2D( model.nInput, ...
                                  model.nHidden,...
                                  model.nConns,...
                                  model.sigma,...
                                  model.ac.debug);
  end;
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [Con, hpl, mu] = de_connector1D(nPixels,nHidden,n_Conn,sigma,dbg)
  %
    hpl = 1;
    x=1:nPixels+1;
    Con=zeros(2*nPixels+nHidden);
    C=zeros(nHidden,nPixels);
    
    switch (nHidden)

      case 6
        mu=(2:5:27);
      
      case 10
        mu=(1:3:28);
      
      case 11
        mu=(1:2.75:28.5);
      
      case 12
        mu=(.75:2.5:28.25);
        
      case 13
        mu=(1:2.25:28);
        
      case 14
        mu=(2:2:28);
        
      case 15
        mu=[1,3,5,6,8,10,11,13,15,16,18,20,21,23,25]; %begin making the connections...
        
      case 29
        mu = 1:29;
        
      otherwise
        error('1D connector not set up to handle %d hidden nodes.', nHidden);
    end
    
    for k=1:nHidden;
        y=normcdf(x,mu(k),sigma);
        Area=max(y)-min(y);
        j=1;
        while(j<=n_Conn)
            N=rand(1)*Area+min(y);
            for i=1:nPixels
                if (N>=y(i)&&N<y(i+1))
                    if(C(k,i)==1)
                        break
                    end
                    C(k,i)=1;
                    j=j+1;
                    break
                end
            end
        end
    end
    Con(nPixels+1:nPixels+nHidden,1:nPixels)=C;
    Con(nPixels+nHidden+1:end,nPixels+1:nPixels+nHidden)=C';%...end making the connections
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [tmp,hpl] = de_connector2D_orig(sH,dbg)
  % Assumes image size 31x13
  %
  % output:
  %
  % tmp     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  % hpl  - hidden units per location
 
  
    hpl = 1; %try to place each hidden unit separately, if possible
    sI = [31 13];
    
    % Assumes image size [31 13]
    switch (sH)
      case 10
        tmp=zeros(sI);
        tmp(2:7:end,4:6:end)=1;
        
      case 11
        tmp=zeros(sI);
        tmp(2:7:end,4:6:end)=1;
        tmp(16,7)=1;
        
      case 12
        tmp=zeros(sI);
        tmp(2:9:end,2:5:end)=1;
        
      case 13
        tmp=zeros(sI);
        tmp(6:10:end,3:4:end)=1;
        tmp(11:10:21,5:4:9)=1;
        
      case 14
        tmp=zeros(sI);
        tmp(4:4:end,4:6:end)=1;
        
      case 15
        tmp=zeros(sI);
        tmp(4:6:end,3:4:end)=1;
        
      case 16
        tmp=zeros(sI);
        tmp(3:4:end,4:6:end)=1;
        
      case 20
        tmp=zeros(sI);
        tmp(4:6:end,2:3:end)=1;
        
      case 22
        interval=floor(sI(1)*sI(2)/21);
        tmp=zeros(sI);
        tmp=reshape(tmp,1,sI(1)*sI(2));
        tmp(2:interval:end)=1;
        tmp=reshape(tmp,sI);
        
      case 25
        tmp=zeros(sI);
        tmp(4:6:end,3:2:end)=1;
        
      case 60
        tmp=zeros(sI);
        tmp(2:3:end,2:2:end)=1;
        
      case 90
        tmp=zeros(sI);
        tmp(2:2:end,2:2:end)=1;
        
      case 202;
        tmp=zeros(sI);
        tmp=reshape(tmp,1,sI(1)*sI(2));
        tmp(1:2:end)=1;
        tmp=reshape(tmp,sI);
        
      otherwise
        % Place 
        sH_factors = sort(factor(sH));
        unique_factors = unique(sH_factors);
        
        % Try to find some grid, and place multiple hidden units at the given locations
        if (length(sH_factors)>1)
          for i=1:length(unique_factors)
            hpl = unique_factors(i);
            try
              [tmp,hpl2] = de_connector2D_orig(sH / hpl, dbg);
              %keyboard
              hpl = hpl * hpl2;
              break; %effort worked, so exit!
            catch
              % unexpected error
              if (isempty(findstr('2D Connector not set up', lasterr)))
                  keyboard
                  error(lasterr);
              % effort failed, so continue looping
              else
                continue;
              end;
            end;
          end;
        end;
        
        if (~exist('tmp','var'))
          error('2D Connector not set up to distribute %d nodes.', sH);
        end;
    end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [tmp,hpl,m] = de_connector2D_internal(sI,sH,dbg)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % tmp     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  % hpl  - hidden units per location
 
  
    [tmp,hpl] = de_connector2D_orig(sH, dbg);
    
    guru_assert( length(find(tmp))*hpl == sH );

    % Stretch, thresshold, and cluster
    if (sI(1)~=31 || sI(2) ~= 13)
      tmp2 = imresize(tmp,sI);
      tmp2(find(tmp2<0.5)) = 0;
      for i=2:size(tmp2,1)-1
        for j=2:size(tmp2,2)-1
          patch = tmp2(i-1:i+1, j-1:j+1);
          [n,I] = max(patch(:));
          
          if (tmp2(i,j) ~= n)
            tmp2(i,j) = 0;
          elseif (length(find(patch==n))~=1)
            tmp2(i,j) = 0;
          else
            tmp2(i,j) = 1;
          end;
        end;
      end;
      tmp = tmp2;
    end;
    
    [row,col] = find(tmp==1);
    [m] = [col,row];
    
    if (ismember(2,dbg))
        %pcolor(tmp);
        %tmp
        nRows = ceil(sqrt((sH+1)*4/3));
        nCols = ceil((sH+1)/nRows);
        
        subplot(nRows,nCols,1);
        imagesc(tmp); title('Hidden node locations');
    end;

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [Con,hpl,tmp] = de_connector2D(sI,sH,numCon,s,dbg)
  %
  %This function is used to creat the connectivity matrix for the
  %  autoencoders based on a Gaussian distribution.
  %
  % Input:
  %  s=sigma (width of Gaussian)
  %  numCon= number of connection per hidden node
  %  sI is a 1x2 matrix containg [height, width] of the input layer (input
  %    images)
  %  sH= # of hidden nodes
  %
  % Output:
  %  Con
  
    %  sO= output layer size; for an autoenc. it is the same as sI
    sO = sI;

    %s=[sI(1)/sI(2) 1]*s; %use this line for a non-circular Gaussian surface...
    s=[1 1]*s;  %or this line for a circular one
    inPix=prod(sI);              %total number of nodes in the input layer
    Con = zeros(2*inPix+sH); %
    halfCon = zeros(sH,inPix); %autoencoders have summetric connections, so you
    %only need to set connections for half of the connectivity matric: the half corresponding
    %to connections between Input to Hidden layers

    x=0:sI(1);xx=1:sI(1);
    y=0:sI(2);yy=1:sI(2);

    [tmp,hpl,m] = de_connector2D_internal(sI, sH, dbg);
    nLoc = size(m,1);
   
    for h=1:hpl %loop over # of units per locust
      for i=1:nLoc %loop over all loci
          %this for loop samples from the Gaussian independetly in the X and Y directions
          hi = (h-1)*(sH/hpl)+i; % unit # in sH, from 1:sH
          
          layer=zeros(sI);
          z1=normcdf(xx,m(i,2),s(1));
          z2=normcdf(yy,m(i,1),s(2));
          z1t=normcdf(x,m(i,2),s(1));
          z2t=normcdf(y,m(i,1),s(2));

          count=0;        % this while loop makes sure all nodes have equal # of connections
          while(count<numCon)
              N1=min(z1t)+(1-min(z1t))*rand;
              N2=min(z2t)+(1-min(z2t))*rand;
              X=0; Y=0;
              for j=1:sI(1)
                  if(N1<z1(j))
                      X=j;
                      break;
                  end
              end
              for k=1:sI(2)
                  if(N2<z2(k))
                      Y=k;
                      break;
                  end
              end
              if ((X~=0)&&(Y~=0)&&layer(X,Y)~=1)
                  layer(X,Y)=1;
                  count=count+1;
              end
          end
          halfCon(hi,:)=reshape(layer,1,inPix);
      end
    end;
    Con(inPix+1:inPix+sH,1:inPix)=halfCon;
    Con(inPix+sH+1:end,inPix+1:inPix+sH)=halfCon';

