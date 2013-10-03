function [model,o_p] = guru_nnTrain_resilient_homeostatic(model,X,Y)
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
    end;
    if isfield(model, 'avgact2')
        huidx = nInputs+1+[1:nHidden];
        huacts = opc(huidx,:);
        meanact = mean(abs(huacts),2);
        
        huidx = huidx(meanact~=0);
        meanact = meanact(meanact~=0);
        keyboard;
        model.Weights(huidx,1:(nInputs+1)) = model.avgact * model.Weights(huidx,1:(nInputs+1)) ./ repmat(meanact,[1 nInputs+1]);
        %keyboard
    elseif isfield(model, 'avgact') %Sullivan & de sa (2006)
        huidx = nInputs+1+[1:nHidden];
        huacts = opc(huidx,:);
        meanact = mean(abs(huacts),2);

        % mean activity from previous time; time window
        if ~exist('avgact','var'), avgact = zeros(size(meanact)); end;
        avgact = model.bc*meanact+(1-model.bc)*avgact;
        actnorm = 1+model.bn*(avgact - model.avgact)./model.avgact;
        %fprintf('avgact=%f, actnorm=%f\n',mean(avgact(find(avgact))), mean(actnorm(find(avgact))));
        
        %if mean(avgact(find(avgact))) > model.avgact, keyboard; end;
        huidx = huidx(meanact~=0); actnorm=actnorm(meanact~=0);    
        model.Weights(huidx,1:(nInputs+1)) = model.Weights(huidx,1:(nInputs+1)) ./ repmat(actnorm,[1 nInputs+1]);
        %keyboard


    elseif isfield(model, 'meanwt')
        huidx = nInputs+1+[1:nHidden];
        huwts = model.Weights(huidx,1:(nInputs+1));
        meanwt = mean(abs(huwts),2);

        huidx = huidx(meanwt~=0);
        meanwt = meanwt(meanwt~=0);
        model.Weights(huidx,1:(nInputs+1)) = model.meanwt * model.Weights(huidx,1:(nInputs+1)) ./ repmat(meanwt,[1 nInputs+1]);
    elseif isfield(model, 'totwt')
        huidx = nInputs+1+[1:nHidden];
        huwts = model.Weights(huidx,1:(nInputs+1));
        totwt = sum(abs(huwts),2);

        huidx = huidx(totwt~=0);
        totwt = totwt(totwt~=0);
        model.Weights(huidx,1:(nInputs+1)) = model.totwt * model.Weights(huidx,1:(nInputs+1)) ./ repmat(totwt,[1 nInputs+1]);
        
    elseif isfield(model, 'stdact')
        inidx = [1:nInputs];
        huidx = nInputs+1+[1:nHidden];
        inacts = opc(inidx,:);
        huacts = opc(huidx,:);
        std_inact = std(abs(inacts),[],2);
        std_huact = std(abs(huacts),[],2);

        % exponential decay
        if ~exist('stdact','var'), stdact = zeros(size(std_huact)); end;
        stdact = model.bc*std_huact+(1-model.bc)*stdact;
        stdnorm = 1+model.bn*(stdact - model.stdact)./model.stdact;
        fprintf('current_std=%f, stdact=%f, stdnorm=%f\n',mean(std_inact(find(std_inact))), mean(stdact(find(stdact))), mean(stdnorm(find(stdact))));
        %keyboard
        %if mean(avgact(find(avgact))) > model.avgact, keyboard; end;
        %huidx = huidx(std_huact~=0); stdnorm=stdnorm(std_huact~=0);    
        model.Weights(huidx,inidx) = model.Weights(huidx,inidx) + 1000.*model.Conn(huidx,inidx).*((stdnorm-mean(stdnorm))*-1*(std_inact-mean(std_inact))'); %neg for too small
        %keyboard
        
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


