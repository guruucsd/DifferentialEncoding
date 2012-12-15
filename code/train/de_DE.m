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

  % Resetting the random state in debug mode
  % allows us to have exactly reproducible results.
  
  if (~isfield(model,'nOutput')), model.nOutput = model.nInput; end;

  %nDims = length(model.nInput);
  nPixels = prod(model.nInput);
  
  %--------------------------------%
  % Create and train the autoencoder
  %--------------------------------%

  rand ('state',model.ac.randState);
  randn('state',model.ac.randState);

  %% NEW CHANGE: LINEAR HIDDEN->OUTPUT UNITS
  flg       = (length(model.ac.XferFn)==1);
  
  % Renormalize inputs based on XferFn?
  
  if (model.ac.cached == 0)
    
    % Set up input/output pairs
    X = model.data.train.X;

    Y = model.data.train.X(1:end-1,:);
    
    % Train
    if (flg)
      model.ac.XferFn = [model.ac.XferFn*ones(1,model.nHidden) ones(1,prod(model.nOutput))]; %linear hidden->output
    end;
    
    % Create connectivity
    model.ac.Conn    = de_connector(model);
    
    % Initialize weights
    model.ac.Weights = model.ac.WeightInitScale*guru_nnInitWeights(model.ac.Conn, model.ac.WeightInitType);
    
    

    % Save memory, if possible
    if (isfield(model, 'p'))
      [model.ac,o] = guru_nnTrainAC(model.ac,X, Y);

    else
      [model.ac]   = guru_nnTrainAC(model.ac,X, Y);

    end;
    clear('X', 'Y');
    
    if (any(isnan(model.ac.Weights)))
        warning('Nan weights; chances are, your learning rate got too big.');
    end;
    
    % report results to screen
    fprintf('| e_AC(%5d): %6.5e',size(model.ac.err,1),model.ac.avgErr);

    if (isfield(model.ac, 'Weights'))
      mn = 0+min(min(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
      mx = 0+max(max(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
      fprintf(' wts=[%5.2f %5.2f]', mn,mx)
    end;

  elseif (isfield(model, 'p') && model.p.cached == 0)
        % Make sure the autoencoder's connectivity is set.
        model = de_LoadProps(model, 'ac', 'Weights');
          
        if (flg)
          model.ac.XferFn = [model.ac.XferFn*ones(1,model.nHidden) ones(1,prod(model.nOutput))]; %linear hidden->output
        end;
          
        % Calculate forward pass through autoencoder
        [~,~, o] = emo_backprop( model.data.train.X, model.data.train.X, model.ac.Weights, double(model.ac.Weights ~= 0), model.ac.XferFn, model.ac.errorType);
        o          = reshape(o, [1 size(o)]);
    
        fprintf('| (cached)');
  end;
    
  if (flg)
      model.ac.XferFn = model.ac.XferFn(1);
  end;
  
  %--------------------------------%
  % Create and train the perceptron
  %--------------------------------%
  if (isfield(model, 'p'))
      rand ('state',model.p.randState);
      randn('state',model.p.randState);

      if (~model.p.cached)  
        goodTrials = ~isnan(sum(model.data.train.T,1));
        nTrials    = sum(goodTrials); % count the # of trials with no NaN anywhere in them  

        % Use hidden unit enncodings as inputs
        X    = reshape(o(end,nPixels+1:nPixels+model.nHidden,goodTrials), [model.nHidden nTrials]);
        X    = X - repmat(mean(X), [size(X,1) 1]); %zero-mean the code
        %X    = X ./ repmat( std(X, 0, 2), [1 nTrials] );
        clear('o'); 

        % Add bias
        if (model.p.useBias)
            biasArray=ones(1,nTrials);
            X     = [X;biasArray];  %bias is last input
            clear('biasArray');
        end;
        
        % Set up connectivity matrix:
        % 1:size(X,1) : inputs units (& bias?) to p
        %      : bias unit
        % nHidden+2:end : output unit(s)
        pInputs         = size(X,1);
        pHidden         = model.p.nHidden;
        pOutputs        = size(model.data.train.T,1);
        pUnits          = pInputs + pHidden + pOutputs;
        model.p.Conn    = false( pUnits, pUnits ); 

        model.p.Conn(pInputs+[1:pHidden],          [1:pInputs])=true; %input->hidden 
        model.p.Conn(pInputs+pHidden+[1:pOutputs], pInputs+[1:pHidden])=true; %hidden->output
        
        model.p.Weights = model.p.WeightInitScale*guru_nnInitWeights(model.p.Conn, ...
                                                                     model.p.WeightInitType);

        % Train
        [model.p,o_p] = guru_nnTrain(model.p,X,reshape(model.data.train.T(:,goodTrials),[pOutputs nTrials]));
        avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
        fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);
        if (isfield(model.p, 'Weights'))
            fprintf(' wts=[%5.2f %5.2f]', min(model.p.Weights(:)), max(model.p.Weights(:)))
        end;


        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        model.p            = rmfield(model.p, 'err'); 

        model.p.output     = reshape(o_p(:,end-pOutputs+1:end,:), ...
                                     [model.p.Iterations pOutputs*nTrials]); 
        
        model.p.lastOutput = model.p.output(end,:);
      end;
  end;    
