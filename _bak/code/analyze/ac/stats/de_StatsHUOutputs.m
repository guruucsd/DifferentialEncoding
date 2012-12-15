function huouts = de_StatsHUOutputs(mss, dset)

  huouts = cell(size(mss));
  %nImages = size(dset.X, 2);
  
  for i=1:length(mss)
    model     = mss{i}(1);
    huouts{i} = zeros([length(mss{i}), model.nHidden, model.nInput]);
    
    for j=1:length(mss{i})
    
      fprintf( '%d ', j);
      
      model = de_LoadProps(mss{i}(j), 'ac', 'Weights');
      inPix = prod(model.nInput);
      Y     = zeros(inPix, 1);
      W     = model.ac.Weights( inPix+1:end, inPix+1:end );
      C     = (W~=0);

      % Produce hidden unit activations  
      for hu=1:model.nHidden
        X = zeros(model.nHidden, 1);
        X(hu) = 1;       % Set the input to have only that node on
        
        % Propagate the activation
        [err,grad,out]=emo_backprop(X, Y, W, C, model.ac.XferFn, 1 ); %constants are dummies
        clear('err','grad');
      
        huouts{i}(j,hu,:,:) = reshape(out((model.nHidden+1):end), model.nInput);
        clear('out');
      end;
    end;

    fprintf('\t');
  end;
  