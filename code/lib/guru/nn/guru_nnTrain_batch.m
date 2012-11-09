function [model,o_p] = guru_nnTrain_batch(model,X,Y)
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
  for ip = 0:model.MaxIterations

    % Inject noise into the input
    if (isfield(model, 'noise_input'))
        X_orig = X;
        X      = X_orig + model.noise_input*(randn(size(X)));

        % Note: don't change Y!!  We don't want to model the noise...
    end;

    % batch
    ep = 1:size(X,2);

    if (exist('o_p', 'var'))
      [m, c, l, g, o] = guru_nnTrain_inner(X, Y, model, model.errorType, ep, ip, currErr, grad);
    else
      [m, c, l, g   ] = guru_nnTrain_inner(X, Y, model, model.errorType, ep, ip, currErr, grad);
    end;

    % If it's good, update.  Otherwise, step-size will be shrunk, so preserve the same gradient, but take a smaller step!
    if (ip==0 || c<l || (isfield(model, 'dropout' && model.dropout>0))
       model = m;
       currErr = c;
       lastErr = l;
       grad = g;
    else % bad, so just update some parameters and try again
       model.Eta    = m.Eta; % update the step-size
       model.lambda = m.lambda; % update the step-size
       if (ip>1), model.err(ip,:) = model.err(ip-1,:); end; % hack since ip=0 and ip=1 write to first row of model.err
    end;
    if ((ip>0) && exist('o_p','var')), o_p(ip,:,ep) = o; end;

    % Finished training
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');


    elseif (currErr <= model.Error)
      if (ip == 0), ip=1; end; % breaks stuff if we say that no updates occurred.  Doubt this is the "right" thing.

      if (ismember(3, model.debug))
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
