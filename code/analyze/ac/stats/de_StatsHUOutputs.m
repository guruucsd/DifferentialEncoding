function huouts = de_StatsHUOutputs(mss, dset)

  global selectedHUs;

  nHUs = 20; % max # HUs we want
  if (isempty(selectedHUs) || (max(selectedHUs)>size(dset.X,2))) %so that all reproductions use the same set
      [un_lbls,imgIdx] = unique(dset.XLAB);
      selectedHUs   = randperm(length(un_lbls)); %so that we get to see a variety
      selectedHUs   = selectedHUs( unique(round(linspace(1, length(un_lbls), nHUs))) );
      selectedHUs   = sort(imgIdx(selectedHUs)) % so that they're grouped by stimulus type
  end;
  nHUs = length(selectedHUs); % # HUs we got
  
  
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
      for hu=1:nHUs
        X = zeros(1+model.nHidden, 1);
        X(1)  = model.ac.useBias; % bias node
        X(hu) = 1;                % Set the input to have only that node on
        
        % Propagate the activation
        [~,~,huo]=emo_backprop(X, Y, W, C, model.ac.XferFn, 1 ); %constants are dummies
        huo = huo(huo((model.nHidden+2):end)
        huouts{i}(j,hu,:,:) = reshape(huo((model.nHidden+2):end), model.nInput);
        clear('out');
      end;
    end;

    fprintf('\t');
  end;
  