function [model, currErr, lastErr, newgrad, o_p] = guru_nnTrain_inner(X, Y, m, errorType, ep, ip, lastErr, lastgrad)
    if (ip==0), ip=1; end; % hack for now; doesn't really matter as it'll all get overwritten
    %if (ip==5) && lastErr<124, keyboard; end;
    
    model = m; % default: output the same things as we got on input.  Only update what we want to change.
    
    %% Update with the last grad
    m.Weights=m.Weights - m.Eta.*m.Conn.*lastgrad;
    if (isfield(model, 'lambda')),
        m.Weights = m.Weights * (1-m.lambda);
    end;
    if (any(isnan(m.Weights(:))))
        error('model weights nan');
    end;
    if (isfield(m, 'wmax'))
        m.Weights = sign(m.Weights).*min(abs(m.Weights), m.wmax);
    elseif (isfield(m, 'wlim'))
        m.Weights(m.Weights<m.wlim(1)) = m.wlim(1);
        m.Weights(m.Weights>m.wlim(2)) = m.wlim(2);
    end; % max weights


    %% Determine model error based on that update
    if isfield(model,'dropout') && model.dropout>0
        wOrig = m.Weights;
        cOrig = m.Conn;
        nIn = size(X,1); nOut = size(Y,1); nHid = size(m.Conn,1)-nIn-nOut;
        idxHOut = rand(nHid,1)<model.dropout;
        m.Conn(nIn+idxHOut, 1:nIn) = false;
        m.Weights(nIn+idxHOut, 1:nIn) = 0;
        m.Conn(nIn+nHid+[1:nOut], nIn+idxHOut) = false;
        m.Weights(nIn+nHid+[1:nOut], nIn+idxHOut) = 0;
    end;

    if (nargout==5)
        [m.err(ip,ep),newgrad,o_p]= emo_backprop(X, Y, m.Weights, m.Conn, m.XferFn, errorType, m.Pow );
    else
        [m.err(ip,ep),newgrad]    = emo_backprop(X, Y, m.Weights, m.Conn, m.XferFn, errorType, m.Pow );
    end;
    if (isfield(model, 'dropout') && model.dropout>0)
      m.Conn = cOrig;
      m.Weights = wOrig;
    end;

    if (~any(isnan(m.err(ip,ep))))
        currErr = sum(m.err(ip,ep));
    else
        curErr  = NaN; % will avoid overwriting...
    end;


    %% Figure out if that update was any good

    % Had a problem; probably moving too fast.
    if (any(isnan(m.err(ip,ep))))
      model.Eta = model.Eta/model.Dec;
      model.err = m.err;
      fprintf('*');

    % We're getting worse, slow things down
    elseif( currErr > lastErr && (ip/model.MaxIterations > 0.00)) % don't start decelerating until after at least 5% of iterations
      model.Eta=model.Eta/model.Dec;
      model.err = m.err;
      fprintf('*');

    % We're getting better, speed things up
    elseif (currErr < lastErr)
      model = m; % keep all changes! yeah!
      model.Eta=model.Eta*model.Acc;
    end;





    % Don't train on weights for inputs that have zero variance.
    %s = std(X,[],2);
    %if (length(find(s==0)>0) && ismember(1, model.debug)), fprintf('  [%d/%d] ', length(find(s)), size(s,1)); end;
    %model.Weights( (nInputs+(1:nHidden)), find(s==0) ) = 0; % input->hidden; set weight to
    %model.Weights( (nInputs+nHidden+(find(s==0))), (nInputs+(1:nHidden)) ) = 0; % hidden->output

    %if (~isfield(model,'Error')), model.Error = model.AvgError*prod(length(find(s))*size(Y,2)); end;

    % Don't train on weights for inputs that have zero variance.
    %s = std(X,[],2);
    %if (length(find(s==0)>0) && ismember(1, model.debug)), fprintf('  [%d/%d] ', length(find(s)), size(s,1)); end;
    %model.Weights( (nInputs+(1:nHidden)), find(s==0) ) = 0; % input->hidden; set weight to
    %model.Weights( (nInputs+nHidden+(find(s==0))), (nInputs+(1:nHidden)) ) = 0; % hidden->output

    %if (~isfield(model,'Error')), model.Error = model.AvgError*prod(length(find(s))*size(Y,2)); end;
