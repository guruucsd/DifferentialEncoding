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

  switch length(model.nInput)
    case 1, error('1D NYI');
    case 2
	  [Con, mu] = de_connector2D(model.nInput, ...
									  model.nHidden, ...
									  model.hpl,...
									  model.nConns,...
									  model.distn{1}, ...
									  model.mu,...
									  model.sigma,...
									  model.ac.debug, ...
									  model.ac.tol);
			if (model.ac.debug), fprintf('!'); end;
			
    otherwise
        nPix         = prod(model.nInput(1:2));
        nInputLayers = prod(model.nInput(3:end));
        nHidPerLayer = model.nHidden/nInputLayers;
        Con = sparse( 2*prod(model.nInput) + model.nHidden, 2*prod(model.nInput) + model.nHidden );
        
        for i=1:nInputLayers
        
            [C, mu] = de_connector2D(model.nInput(1:2), ...
										  model.nHidden/nInputLayers, ...
										  model.hpl,...
										  model.nConns,...
										  model.distn{1}, ...
										  model.mu,...
										  model.sigma,...
										  model.ac.debug, ...
										  model.ac.tol);
										  
            Con( prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer], (i-1)*nPix+[1:nPix]) = C(nPix+[1:nHidPerLayer],[1:nPix]); %Input->Hidden
            Con( prod(model.nInput) +model.nHidden + (i-1)*nPix + [1:nPix], prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer]) = C(nPix+nHidPerLayer+[1:nPix], nPix+[1:nHidPerLayer]); %Hidden->Output
		end;
	end;
	
    % Add bias node connections
    nInput = prod(model.nInput);
    
    Con = [Con(1:nInput,:); ... % add empty row
             zeros(1, size(Con,2));  ... %it's the last input
             Con(nInput+1:end, :)]; 
    Con = [Con(:,1:nInput) ... % add empty column: nobody connects TO bias
             zeros(size(Con,1),1)  ... %it's the last input
             Con(:,nInput+1:end)]; 

    Con(nInput+1,nInput+2:end) = model.ac.useBias; %add row for connections from bias to inputs,hidden,output
