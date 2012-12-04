function [model,o_p] = guru_nnTrain_resilient(model,X,Y)
% Train with basic backprop, in batch mode

  nInputs   = size(X,1)-1;
  nDatapts  = size(X,2);
  nUnits    = size(model.Weights,1);
  nOutputs  = size(Y,1);
  nHidden   = nUnits - nInputs - nOutputs -1; % extra one is bias

  model.err = zeros([model.MaxIterations nDatapts]);

  % Only do if necessary, for memory reasons
  if (nargout>1)
      o_p       = zeros([model.MaxIterations nUnits nDatapts]);
  end;

  if (~isfield(model,'Error'))
    model.Error = model.AvgError*numel(Y);
  end;

  if ~isfield(model, 'Eta')
    model.Eta = sparse(model.EtaInit.*model.Conn);
  else
    model.Eta = model.Eta.*model.Conn; % validate that we won't train any non-connections
  end;

%  lastErr   = NaN;
  currErr   = NaN;
  lastGrad  = spalloc(size(model.Conn,1), size(model.Conn,2), nnz(model.Conn));


  for ip = 1:model.MaxIterations
    % Inject noise into the input
    if (isfield(model, 'noise_input'))
        X_orig = X;
        X      = X_orig + model.noise_input*(randn(size(X)));

        % Note: don't change Y!!  We don't want to model the noise...
    end;

    %% Determine model error based on that update
    if isfield(model,'dropout') && model.dropout>0
        wOrig = model.Weights;
        cOrig = model.Conn;
        idxHOut = find(rand(nHidden,1)<model.dropout);
        model.Conn(   nInputs+1+idxHOut, 1:(nInputs+1)) = false;
        model.Weights(nInputs+1+idxHOut, 1:(nInputs+1)) = 0;
        model.Conn(   nInputs+1+nHidden+[1:nOutputs], nInputs+1+idxHOut) = false;
        model.Weights(nInputs+1+nHidden+[1:nOutputs], nInputs+1+idxHOut) = 0;
    end;

    % Determine model error
    [model.err(ip,:),grad, opc]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType, model.Pow );
    if (nargout>1)
        o_p(ip,:,:) = opc;
    end;

    if (isfield(model, 'dropout') && model.dropout>0)
      model.Conn = cOrig;
      model.Weights = wOrig;
    end;

    % Change error only if there are no NaN
    if (any(isnan(model.err(ip,:))))
        lastErr = currErr;
    else
        lastErr = currErr;
        currErr = sum(model.err(ip,:));
    end;

    % Had a problem; probably moving too fast.
    if (any(isnan(model.err(ip,:))))
      break;
    end;

    %% Do checks before applying gradient, as error is for CURRENT weights,
    %% not for weights after weight change!!

    % Finished training
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');


    elseif (currErr <= model.Error)
      %keyboard
      if (ismember(13, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
      end;
      break;

    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      warning(sprintf('Error didn''t change on iteration %d; done training early.\n',ip));
      keyboard
      break;
    end;

    if (ismember(10, model.debug)), fprintf('[%4d]: err = %6.4e\n', ip, currErr/numel(Y)); end;

    % Adjust the weights
    guru_assert(~any(isnan(grad(:))));
    model.Weights=model.Weights-model.Eta.*model.Conn.*sign(grad);
    if (isfield(model, 'lambda') && currErr < lastErr)
        model.Weights = model.Weights .* (1-model.lambda);
    elseif true || isfield(model, 'avgact')
        model.avgact = 0.01;
        huidx = nInputs+1+[1:nHidden];
        huacts = opc(huidx,:);
        meanact = mean(abs(huacts),2);
        
        huidx = huidx(meanact~=0);
        meanact = meanact(meanact~=0);
        model.Weights(huidx,1:(nInputs+1)) = model.avgact * model.Weights(huidx,1:(nInputs+1)) ./ repmat(meanact,[1 nInputs+1]);
        %keyboard
    elseif true || isfield(model,'meanwts')
        
    end;
    guru_assert(~any(isnan(model.Weights(:))));
    if (isfield(model, 'wmax'))
        over_wts = abs(model.Weights)>model.wmax;
        model.Weights(over_wts) = sign(model.Weights(over_wts)) .* model.wmax;
    elseif (isfield(model, 'wlim'))
        model.Weights(model.Weights<model.wlim(1)) = model.wlim(1);
        model.Weights(model.Weights>model.wlim(2)) = model.wlim(2);
    end;

    % We're getting better, speed things up
    samesign  = sparse((sign(grad) + sign(lastGrad)) ~= 0);
    model.Eta =model.Eta + ((model.Acc)*currErr.*samesign);
    model.Eta =model.Eta.*(1 - ((model.Dec).*(~samesign)));

    lastGrad = grad;
  end;

%  model = rmfield(model,'Eta');

  % Allows for multiple training calls (to save a history)
  if (~isfield(model, 'Iterations')), model.Iterations = []; end;
  model.Iterations(end+1)    = ip;

  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations(end),:,:);
  end;


