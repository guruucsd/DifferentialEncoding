function [model] = de_DE_Multi(model)
%function [model] = de_DE_Multi(model)
%
% Train differential encoder.
%    First: train the autoencoder with different connectivity.
%    Then: train a 4-layer classification network, with inputs from pixels, and
%      input->hidden1 weights from the autoencoder network.
%      While training the classifier, also continue training the autoencoder
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
        Y_train = [model.data.train.X(1:end-1,:); model.data.train.T];

        % Set up connectivity matrix:
        pInputs         = size(X_train,1);
        acHidden        = model.nHidden;
        pHidden         = model.p.nHidden;
        acOutputs       = size(X_train,1)-1;
        pOutputs        = size(model.data.train.T,1);
        pUnits          = pInputs + acHidden+pHidden + acOutputs+pOutputs;

        if (~model.p.continue)
            model.p.Conn    = false( pUnits, pUnits );
            model.p.Conn(1:(pInputs+acHidden), 1:(pInputs+acHidden)) = model.ac.Conn(1:(pInputs+acHidden), 1:(pInputs+acHidden)); %input=>acHidden
            model.p.Conn(pInputs+acHidden+[1:pHidden],  pInputs+[1:acHidden]) = true; %acHidden=>pHidden
            model.p.Conn(pInputs+acHidden+pHidden+[1:acOutputs],  pInputs+[1:acHidden]) = true; %acHidden=>acOutput
            model.p.Conn(pInputs+acHidden+pHidden+acOutputs+[1:pOutputs], pInputs+acHidden+[1:pHidden])=true; %pHidden=>pOutput
            model.p.Conn((pInputs+1):pUnits, pInputs) = (model.p.useBias~=0); %bias=>all

            model.p.Weights = model.p.WeightInitScale*guru_nnInitWeights(model.p.Conn, ...
                                                                         model.p.WeightInitType);
            model.p.Weights(pInputs+[1:acHidden], 1:pInputs) = model.ac.Weights(pInputs+[1:acHidden], 1:pInputs); %input=>acHidden
            model.p.Weights(pInputs+acHidden+pHidden+[1:acOutputs], pInputs+[1:acHidden]) = model.ac.Weights(pInputs+acHidden+[1:acOutputs], pInputs+[1:acHidden]); %acHidden=>acOutputs
            model.p.Weights(pInputs+[1:acHidden], pInputs) = model.ac.Weights(pInputs+[1:acHidden], pInputs); %bias=>acHidden
            model.p.Weights(pInputs+acHidden+pHidden+[1:acOutputs], pInputs) = model.ac.Weights(pInputs+acHidden+[1:acOutputs], pInputs); %bias=>acHidden
        end;

        % Train
        [model.p] = guru_nnTrain(model.p, X_train(:,good_train), Y_train(:,good_train));
        avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
        fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);
        if (isfield(model.p, 'Weights'))
            fprintf(' wts=[%5.2f %5.2f]', full(min(model.p.Weights(:))), full(max(model.p.Weights(:))))
        end;
        model.p            = rmfield(model.p, 'err');

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        o_p = guru_nnExec(model.p, X_train(:,good_train), Y_train(:,good_train) );
        model.p.output.train = o_p(acOutputs+[1:pOutputs],:);

        % TEST
        X_test = model.data.test.X;
        Y_test = [model.data.test.X(1:end-1,:); model.data.test.T];

        good_test  = ~isnan(sum(model.data.test.T,1));
        nTest      = sum(good_test); % count the # of trials with no NaN anywhere in them

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        o_p = guru_nnExec(model.p, X_test(:,good_test), Y_test(:,good_test) );
        model.p.output.test = o_p(acOutputs+[1:pOutputs],:);
        mean(model.p.output.test,1)
    end;
  end;


