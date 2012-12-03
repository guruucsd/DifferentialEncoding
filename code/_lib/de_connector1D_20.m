function [C, mu] = de_connector1D_20(nHidden, n_Conn, sigma)
%
    nPixels = 10; %20/2
    
    switch (nHidden)

      case 4,  mu=find([0 1 0 1 0 0 1 0 1 0]);
%      case 5,  mu=find([1 0 1 0 1 0 0 1 0 1]);
      otherwise, error('1D connector not set up to handle %d hidden nodes.', nHidden);
    end
    
    x  = 1:nPixels+1;
    C  = zeros(nPixels,nHidden);
    
    for k=1:nHidden
        y=normcdf(x,mu(k),sigma);
        Area=max(y)-min(y);
        j=0;
        while(j<n_Conn)
            i = min(nPixels,round(norminv(min(y)+rand(1)*Area,mu(k),sigma))); %sample
            if (i==k), continue; end; % don't allow self-connection
            if (C(i,k)), continue; end;
            
            C(i,k)=1;
            j = j + 1;
        end
    end
    
    if (any(~sum(C,2)))
        fprintf('Warning: algorithm did not connect to %d (of %d) of the inputs; trying again.\n', length(find(~sum(C,2))), nPixels);
        C = de_connector1D_20(nHidden, n_Conn, sigma);
    end;