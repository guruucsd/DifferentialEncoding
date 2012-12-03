function [C, mu] = de_connector1D_42(nHidden, n_Conn, sigma, lorr)
%
    nPixels = 42/2;
    
    switch (nHidden)
        case 10,   mu=find([repmat([0 1], [1 10]) 0]);
        case 20,   mu=sort(repmat(find([repmat([0 1], [1 10]) 0]), [1 2])); 
        case 21,   mu=find(ones(1,21));
        case 30,   mu=sort(repmat(find([repmat([0 1], [1 10]) 0]), [1 3])); 
        case 31,   mu=sort([find([repmat([0 1], [1 10]) 0]) find(ones(1,21))]); 
        case 42,   mu=sort(repmat(find(ones(1,21)), [1 2]));
        case 100,  mu=sort(repmat(find([repmat([0 1], [1 10]) 0]), [1 10])); 
        case 105,  mu=sort(repmat(find(ones(1,21)), [1 5]));
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
        C = feval(getfield(dbstack,'name'), nHidden, n_Conn, sigma);
    end;