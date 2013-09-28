function [model,o_p] = guru_nnTrain_online(model,X,Y)
% Train with basic backprop, in batch mode

  nInputs   = size(Y,1);
  nDatapts  = size(Y,2);
  nUnits    = size(model.Weights,1);
  nOutputs  = nInputs;
  nHidden   = nUnits - nInputs - nOutputs;

  model.err = zeros([model.MaxIterations nDatapts]);

  % Only do if necessary, for memory reasons
  if (nargout>1)
      o_p       = zeros([model.MaxIterations nUnits nDatapts]);
  end;

  if (~isfield(model,'Error'))
    model.Error = model.AvgError*numel(Y);
  end;

  model.Eta = model.EtaInit;
  lastErr   = inf;
  currErr   = inf;
  grad      = zeros(size(model.Conn)); 

  % first loop just assesses the current state of the network; no gradient update
  for ip = 1:model.MaxIterations
    lastErr = currErr;
    currErr = 0;
    for di = 1:nDatapts
      Xc = X(:,di);
      Yc = Y(:,di);

      % Inject noise into the input
      if (isfield(model, 'noise_input'))
          Xc      = Xc + model.noise_input*(randn(size(Xc)));
          % Note: don't change Y!!  We don't want to model the noise...
      end;

      if (exist('o_p', 'var'))
        [m, c, l, grad, o] = guru_nnTrain_inner(Xc, Yc, model, model.errorType, di, ip, currErr, grad);
      else
        [m, c, l, grad   ] = guru_nnTrain_inner(Xc, Yc, model, model.errorType, di, ip, currErr, grad);
      end;
      if di ~= nDatapts
       m.Eta    = model.Eta; % update the step-size
       m.lambda = model.lambda; % update the step-size
      end;
      model = m;
      currErr = currErr + c;
      
      if ((ip>0) && exist('o_p','var')), o_p(ip,:,ep) = o; end;
    end;

    % Finished training
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');


    elseif (currErr <= model.Error)
      if (ip == 0), ip=1; end; % breaks stuff if we say that no updates occurred.  Doubt this is the "right" thing.

      if (ismember(13, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
      end;
      break;

    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      %if (ismember(2, model.debug))
        fprintf('Error didn''t change on iteration %d; done training early.\n',ip);
      %end;
      %break;
    end;
    if (ismember(10, model.debug)), fprintf('[%4d]: err = %6.4e [eta=%5.3e]\n', ip, currErr/numel(Y), model.Eta); end;
  end;


  %model = rmfield(model, 'Eta');
  % Allows for multiple training calls (to save a history)
  if (~isfield(model, 'Iterations')), model.Iterations = []; end;
  model.Iterations(end+1)    = ip;

  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations(end),:,:);
  end;
