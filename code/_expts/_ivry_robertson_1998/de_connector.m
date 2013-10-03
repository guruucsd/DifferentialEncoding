function [Con] = de_connector(model)
%[Con, mu] = de_connector(model)
%
% Creates a connectivity matrix for the given model
%
% Inputs:
% model : see de_model for details
%
% Outputs:
% Con   : connectivity matrix
  
    [Con, hpl, mu] = de_connector1D( prod(model.nInput), ...
                                  model.nHidden,...
                                  model.nConns,...
                                  model.mu,...
                                  model.sigma,...
                                  model.ac.debug);
                                  
                                  
 function [Con, hpl, mu] = de_connector1D(nPixels,nHidden,n_Conn,sigma,dbg)
  %
    [mu,hpl] = de_connector_positions(nHidden,dbg);
    
    x=1:nPixels+1;
    Con=zeros(2*nPixels+nHidden);
    C=zeros(nHidden,nPixels);
    
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
    