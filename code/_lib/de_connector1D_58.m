function [Con, mu] = de_connector1D_29(nHidden, n_Conn, sigma)
%
    hpl = 1;
    nPixels = 29;
    
    switch (nHidden)

      case 6,  mu=(2:5:27);
      case 10, mu=(1:3:28);
      case 11, mu=(1:2.75:28.5);
      case 12, mu=(.75:2.5:28.25);
      case 13, mu=(1:2.25:28);
      case 14, mu=(2:2:28);
      case 15, mu=[1,3,5,6,8,10,11,13,15,16,18,20,21,23,25]; %begin making the connections...
      otherwise, error('1D connector not set up to handle %d hidden nodes.', nHidden);
    end
    
    x  = 1:nPixels+1;
    C  = zeros(nPixels,nHidden);
    
    for k=1:nHidden
        y=normcdf(x,mu(k),sigma);
        Area=max(y)-min(y);
        j=1;
        while(j<=n_Conn)
            i = min(nPixels,round(norminv(min(y)+rand(1)*Area,mu(k),sigma))); %sample
            if (C(i,k)), continue; end;
            
            C(i,k)=1;
            j = j + 1;
        end
    end

    Con= zeros(2*nPixels+nHidden);
    Con(nPixels+1:nPixels+nHidden,1:nPixels)=C';  %input->hidden
    Con(nPixels+nHidden+1:end,nPixels+1:nPixels+nHidden)=C;%...end making the connections
