function [model] = DE(model)
%function [model] = DE(model)
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

  % Resetting the random state in debug mode
  % allows us to have exactly reproducible results.
  
  if (~isfield(model,'nOutput')), model.nOutput = model.nInput; end;

  nDims = length(model.nInput);
  nTrials = size(model.data.train.X,2);  
  
  %--------------------------------%
  % Create and train the autoencoder
  %--------------------------------%

  rand ('state',model.ac.randState);
  randn('state',model.ac.randState);
    %keyboard
  % Need to train  
  if (model.ac.cached == 0)
    
    % Create  
    model.ac.Conn    = de_connector(model);
    model.ac.Weights = guru_nnInitWeights(size(model.ac.Conn), ...
                                          model.ac.WeightInitType);
    
    % Train
    [model.ac,o] = guru_nnTrain(model.ac,model.data.train.X,model.data.train.X);
    
    % report results to screen
    avgErr       = mean(model.ac.err(end,:),2)/prod(model.nOutput);
    fprintf('| e_AC(%5d): %6.5f',size(model.ac.err,1),avgErr);
    
  elseif (model.p.cached == 0)
    if (~isfield(model.p,'output'))
      % Make sure the autoencoder's connectivity is set.
      model = de_LoadProps(model, 'ac', 'Weights');
      [j1,j2, o] = emo_backprop( model.data.train.X, model.data.train.X, model.ac.Weights, double(model.ac.Weights ~= 0), model.ac.XferFn, model.ac.errorType);
      o          = reshape(o, [1 size(o)]);
    end;

    fprintf('| (cached)');
  end;
    
  %--------------------------------%
  % Create and train the perceptron
  %--------------------------------%

  rand ('state',model.p.randState);
  randn('state',model.p.randState);
  
  if (model.p.cached == 0)  
    % Set up inputs
    nPixels = prod(model.nInput);
    code    = reshape(o(end,nPixels+1:nPixels+model.nHidden,:), [model.nHidden nTrials]);
    clear('o'); 
    biasArray=ones(1,nTrials);
    code     = [code;biasArray]; 
    clear('biasArray');
    
    % Set up connections & weights
    pOutputs        = size(model.data.train.T,1);
    
    % Set up connectivity matrix:
    % 1:nHidden     : hidden units
    % nHidden+1     : bias units
    % nHidden+2:end : output units
    model.p.Conn    = zeros(model.nHidden+1+pOutputs); 
    
    % connect hidden units to output units
    model.p.Conn(model.nHidden+2:end,1:model.nHidden+1)=1; 
    model.p.Weights = guru_nnInitWeights(size(model.p.Conn), ...
                                         model.p.WeightInitType);

    % Train
    [model.p,o_p] = guru_nnTrain(model.p,code,reshape(model.data.train.T,[pOutputs nTrials]));
    avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
    fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);

    % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
    model.p            = rmfield(model.p, 'err');  
    model.p.output     = reshape(o_p(:,model.nHidden+2:end,:), ...
                                 [model.p.Iterations pOutputs*nTrials]); 
    % check for crazy case, when niters ==1
    %if (model.p.Iterations == 1)
    %  model.p.output = model.p.output';
    %end;
    
    model.p.lastOutput = model.p.output(end,:);
  end;    
