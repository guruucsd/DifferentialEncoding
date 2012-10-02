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
    model.Error = model.AvgError*numel(Y,1);
  end;
 
  model.Eta = model.EtaInit;
  lastErr   = NaN;
  currErr   = NaN;
  
  for ip = 1:model.MaxIterations

    if (~exist('indivCurrErr','var'))
      indivCurrErr = nan(1,size(X,2));
      indivLastErr = nan(1,size(X,2));
    end;
      
    % random sequence
    gg = randperm(size(X,2));

    for ep =1:size(X,2)
      if (exist('o_p', 'var'))
        [model,indivCurrErr(ep), indivLastErr(ep),o_p(ip,:,ep)] = guru_nnTrain_inner(X(:,gg(ep)), Y(:,gg(ep)), model, model.errorType, ep, ip, indivCurrErr(ep));
      else
        [model,indivCurrErr(ep), indivLastErr(ep)] = guru_nnTrain_inner(X(:,gg(ep)), Y(:,gg(ep)), model, model.errorType, ep, ip, indivCurrErr(ep));
      end;
    end;
    currErr = sum(indivCurrErr);
    lastErr = sum(indivLastErr);

    % Finished training    
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large`');
        
        
    elseif (currErr <= model.Error)
      if (ismember(3, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
      end;
      break;
      
    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      if (ismember(2, model.debug))
        fprintf('Error didn''t change on iteration %d; done training early.\n',ip);
      end;
      break;
    end;
  end;
  
  model = rmfield(model, 'Eta');
  % 
  model.Iterations    = ip;
  
  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations,:,:);
  end;
