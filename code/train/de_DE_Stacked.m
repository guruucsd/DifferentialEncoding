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

  if (~model.ac.cached)

    % Set up input/output pairs
    X = model.data.train.X;
    Y = model.data.train.X(1:end-1,:);

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

  end;

  % Even if it's cached, we need the output characteristics
  %   of the model.
  if (~isfield(model.ac,'hu'))
    % Make sure the autoencoder's connectivity is set.
    model = de_LoadProps(model, 'ac', 'Weights');
    model.ac.Conn = (model.ac.Weights~=0);

    fprintf('| (cached)');

    [model.ac.output.train,~,model.ac.hu.train] = guru_nnExec(model.ac, model.data.train.X, model.data.train.X(1:end-1,:));
    [model.ac.output.test, ~,model.ac.hu.test]  = guru_nnExec(model.ac, model.data.test.X,  model.data.test.X(1:end-1,:));
  end;


  %--------------------------------%
  % Create and train the perceptron
  %--------------------------------%
  if (isfield(model, 'p'))

      if (~model.p.cached)
        good_train = ~isnan(sum(model.data.train.T,1));
        nTrain    = sum(good_train); % count the # of trials with no NaN anywhere in them

        % Use images as inputs
        X_train = model.data.train.X;
        Y_train = model.data.train.X(1:end-1,:);

        % Set up connectivity matrix:
        pInputs         = size(X_train,1);
        pHidden1        = model.nHidden;
        pHidden2        = model.p.nHidden;
        pOutputs        = size(model.data.train.T,1);
        pUnits          = pInputs + pHidden1+pHidden2 + pOutputs;

        if (~model.p.continue)
            model.p.Conn    = false( pUnits, pUnits );
            model.p.Conn(1:(pInputs+pHidden1), 1:(pInputs+pHidden1)) = model.ac.Conn(1:(pInputs+pHidden1), 1:(pInputs+pHidden1));
            model.p.Conn(pInputs+pHidden1+[1:pHidden2],  pInputs+[1:pHidden1]) = true; %hidden1=>hidden2
            model.p.Conn(pInputs+pHidden1+pHidden2+[1:pOutputs], pInputs+pHidden1+[1:pHidden2])=true; %hidden2=>output

            model.p.Weights = model.p.WeightInitScale*guru_nnInitWeights(model.p.Conn, ...
                                                                         model.p.WeightInitType);
            model.p.Weights(1:(pInputs+pHidden1), 1:(pInputs+pHidden1)) = model.ac.Weights(1:(pInputs+pHidden1), 1:(pInputs+pHidden1));
        end;
         
        % Train
        [model.p] = guru_nnTrain(model.p,X_train, reshape(model.data.train.T(:,good_train),[pOutputs nTrain]));
        avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
        fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);
        if (isfield(model.p, 'Weights'))
            fprintf(' wts=[%5.2f %5.2f]', full(min(model.p.Weights(:))), full(max(model.p.Weights(:))))
        end;
        model.p            = rmfield(model.p, 'err');

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        model.p.output.train = guru_nnExec(model.p, X_train, model.data.train.T );
        
      
        % TEST
        X_test = model.data.test.X;
        Y_test = model.data.test.X(1:end-1,:);

        good_test  = ~isnan(sum(model.data.test.T,1));
        nTest      = sum(good_test); % count the # of trials with no NaN anywhere in them

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        model.p.output.test = guru_nnExec(model.p, X_test, reshape(model.data.test.T(:,good_test),[pOutputs nTest]) );
      end;
  end;


