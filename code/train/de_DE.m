function [model] = de_DE(model)
%function [model] = de_DE(model)
%
% Train differential encoder.
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% model     :
%   .LS     : final performance on the different trial types
%   .ac.err : series training error from the autoencoder
%   .p.err  : series training error from the perceptron

  nPixels = prod(model.nInput);

  %--------------------------------%
  % Create and train the autoencoder
  %--------------------------------%

  if (~isfield(model.ac, 'linout')), model.ac.linout = false; end;

  if (~model.ac.cached)

    % Set up input/output pairs
    X = model.data.train.X;
    Y = model.data.train.X(1:end-1,:);

    % Train
    if (model.ac.linout && length(model.ac.XferFn) ~= (model.nHidden+prod(model.nOutput)))
      old_ac_xferfn = model.ac.XferFn;
      model.ac.XferFn = [model.ac.XferFn*ones(1,model.nHidden) ones(1,prod(model.nOutput))]; %linear hidden->output
    elseif (length(model.ac.XferFn)==2)
      old_ac_xferfn = model.ac.XferFn;
      model.ac.XferFn = [model.ac.XferFn(1)*ones(1,model.nHidden) model.ac.XferFn(2)*ones(1,prod(model.nOutput))];
    end;

    % Create connectivity
    if (~model.ac.continue)
        [model.ac.Conn, model.ac.Weights]    = de_connector(model);
    end;

    % Train the model
    [model.ac] = guru_nnTrainAC(model.ac,X);
    clear('X', 'Y');

    % report results to screen
    fprintf('| e_AC(%5d): %6.5e',size(model.ac.err,1),model.ac.avgErr(end));
    mn = 0+min(min(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
    mx = 0+max(max(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
    fprintf(' wts=[%5.2f %5.2f]', mn,mx)

    % Undo expansion of XferFn, for caching purposes
    if (exist('old_ac_xferfn','var'))
        model.ac.XferFn = old_ac_xferfn;
        clear('old_ac_xferfn')
    end;
  end;

  % Even if it's cached, we need the output characteristics
  %   of the model.
  %elseif (~isfield(model.ac,'hu'))
  if (~isfield(model.ac,'hu'))
    % Make sure the autoencoder's connectivity is set.
    model = de_LoadProps(model, 'ac', 'Weights');
    model.ac.Conn = (model.ac.Weights~=0);

    if (model.ac.linout && length(model.ac.XferFn) ~= (model.nHidden+prod(model.nOutput)))
        old_ac_xferfn = model.ac.XferFn;
        model.ac.XferFn = [model.ac.XferFn*ones(1,model.nHidden) ones(1,prod(model.nOutput))]; %linear hidden->output
    elseif (length(model.ac.XferFn)==2)
        old_ac_xferfn = model.ac.XferFn;
        model.ac.XferFn = [model.ac.XferFn(1)*ones(1,model.nHidden) model.ac.XferFn(2)*ones(1,prod(model.nOutput))];
    end;

    fprintf('| (cached)');

    % Calculate forward pass through autoencoder
    [~,~, o_train] = emo_backprop( model.data.train.X, model.data.train.X(1:end-1,:), model.ac.Weights, model.ac.Conn, model.ac.XferFn, model.ac.errorType);
    model.ac.hu.train     = o_train(nPixels+[1:model.nHidden], :);
    model.ac.output.train = o_train(nPixels+model.nHidden+[1:nPixels],:); %Do NOT grab bias
    clear('o_train');

    [~,~, o_test] = emo_backprop( model.data.test.X, model.data.test.X(1:end-1,:), model.ac.Weights, model.ac.Conn, model.ac.XferFn, model.ac.errorType);
    model.ac.hu.test     = o_test(nPixels+[1:model.nHidden], :);
    model.ac.output.test = o_test(nPixels+model.nHidden+[1:nPixels],:); % Do NOT grab bias
    clear('o_test');

    % Undo expansion of XferFn, for caching purposes
    if (exist('old_ac_xferfn','var'))
        model.ac.XferFn = old_ac_xferfn;
        clear('old_ac_xferfn')
    end;
  end;



  %--------------------------------%
  % Create and train the perceptron
  %--------------------------------%
  if (isfield(model, 'p'))

      if (~model.p.cached)
        goodTrials = ~isnan(sum(model.data.train.T,1));
        nTrials    = sum(goodTrials); % count the # of trials with no NaN anywhere in them

        % Use hidden unit enncodings as inputs
        X_train    = model.ac.hu.train;
        X_train    = X_train - repmat(mean(X_train), [size(X_train,1) 1]); %zero-mean the code
        %X_train    = X_train ./ repmat( std(X_train, 0, 2), [1 nTrials] );

        % Add bias
        if (model.p.useBias)
            biasArray=ones(1,nTrials);
            X_train     = [X_train;biasArray];  %bias is last input
            clear('biasArray');
        end;

        % Set up connectivity matrix:
        % 1:size(X,1) : inputs units (& bias?) to p
        %      : bias unit
        % nHidden+2:end : output unit(s)
        pInputs         = size(X_train,1);
        pHidden         = model.p.nHidden;
        pOutputs        = size(model.data.train.T,1);
        pUnits          = pInputs + pHidden + pOutputs;

        if (~model.p.continue)
            model.p.Conn    = false( pUnits, pUnits );

            model.p.Conn(pInputs+[1:pHidden],          [1:pInputs])=true; %input->hidden
            model.p.Conn(pInputs+pHidden+[1:pOutputs], pInputs+[1:pHidden])=true; %hidden->output

            model.p.Weights = model.p.WeightInitScale*guru_nnInitWeights(model.p.Conn, ...
                                                                         model.p.WeightInitType);
        end;

        if (length(model.p.XferFn)==1)
            old_p_xferfn = model.p.XferFn;
            model.p.XferFn = model.p.XferFn*ones(1,pHidden+pOutputs);
        elseif (length(model.p.XferFn)==2)
            old_p_xferfn = model.p.XferFn;
            model.p.XferFn = [model.p.XferFn(1)*ones(1,pHidden) model.p.XferFn(2)*ones(1,pOutputs)];
        end;
         
        % Train
        [model.p] = guru_nnTrain(model.p,X_train,reshape(model.data.train.T(:,goodTrials),[pOutputs nTrials]));
        avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
        fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);
        if (isfield(model.p, 'Weights'))
            fprintf(' wts=[%5.2f %5.2f]', min(model.p.Weights(:)), max(model.p.Weights(:)))
        end;
        model.p            = rmfield(model.p, 'err');

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        [~,~,o_train]=emo_backprop(X_train, model.data.train.T, model.p.Weights, model.p.Conn, model.p.XferFn, model.p.errorType );

        model.p.output.train = o_train(end-pOutputs+1:end,:);

        % Now run the perceptron on the TEST set
        p_test     = model.p;

        good_test  = ~isnan(sum(model.data.test.T,1));
        nTest      = sum(good_test); % count the # of trials with no NaN anywhere in them

        % Use hidden unit enncodings as inputs
        X_test    = model.ac.hu.test;
        X_test    = X_test - repmat(mean(X_test), [size(X_test,1) 1]); %zero-mean the code
        %X_test   = X ./ repmat( std(X_test, 0, 2), [1 nTrials] );
        % Add bias
        if (model.p.useBias)
            biasArray=ones(1,nTest);
            X_test     = [X_test;biasArray];  %bias is last input
            clear('biasArray');
        end;

        [~,~,o_test]=emo_backprop(X_test, model.data.test.T, model.p.Weights, model.p.Conn, model.p.XferFn, model.p.errorType );

        model.p.output.test = o_test(end-pOutputs+1:end,:);
        
        % Now restore xferfn, for caching purposes
        if (exist('old_p_xferfn', 'var'))
          model.p.XferFn = old_p_xferfn;
          clear('old_p_xferfn')
        end;
      end;
  end;


