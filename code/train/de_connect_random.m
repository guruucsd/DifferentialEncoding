function [Con,Wts] = de_connect_random(model)
% Take the connectivity parameters,
%   and create random connections
%   with random initial weights.
%
  if (isfield(model.ac, 'randState'))
      rand('seed', model.ac.randState);
      randn('seed', model.ac.randState);
  end;

  switch length(model.nInput)
    case 1, error('1D NYI');
    case 2
      [Con, mu] = de_connector2D(model.nInput, ...
                                      model.nHidden, ...
                                      model.hpl,...
                                      model.nConns,...
                                      model.distn, ...
                                      model.mu,...
                                      model.sigma,...
                                      model.ac.debug, ...
                                      model.ac.tol);
            if (model.ac.debug), fprintf('!'); end;

    otherwise
        nPix         = prod(model.nInput(1:2));
        nInputLayers = prod(model.nInput(3:end));
        nHidPerLayer = model.nHidden/nInputLayers;
        Con = spalloc( 2*prod(model.nInput) + model.nHidden, 2*prod(model.nInput) + model.nHidden, 2*model.nHidden*model.nConns + 2*prod(model.nInput)+model.nHidden );

        for i=1:nInputLayers

            [C, mu] = de_connector2D(model.nInput(1:2), ...
                                          model.nHidden/nInputLayers, ...
                                          model.hpl,...
                                          model.nConns,...
                                          model.distn, ...
                                          model.mu,...
                                          model.sigma,...
                                          model.ac.debug, ...
                                          model.ac.tol);

            Con( prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer], (i-1)*nPix+[1:nPix]) = C(nPix+[1:nHidPerLayer],[1:nPix]); %Input->Hidden
            Con( prod(model.nInput) +model.nHidden + (i-1)*nPix + [1:nPix], prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer]) = C(nPix+nHidPerLayer+[1:nPix], nPix+[1:nHidPerLayer]); %Hidden->Output
        end;
        if (model.ac.debug), fprintf('\n'); end;

    end;


    % Add bias node connections
    nInput = prod(model.nInput);

    Con = [Con(1:nInput,:); ... % add empty row
             false(1, size(Con,2));  ... %it's the last input
             Con(nInput+1:end, :)];
    Con = [Con(:,1:nInput) ... % add empty column: nobody connects TO bias
             false(size(Con,1),1)  ... %it's the last input
             Con(:,nInput+1:end)];

    Con(nInput+1,nInput+2:end) = (model.ac.useBias~=0); %add row for connections from bias to inputs,hidden,output

    % Initialize weights
    if (nargout > 1)
        Wts = model.ac.WeightInitScale*guru_nnInitWeights(Con, model.ac.WeightInitType);
    end;
