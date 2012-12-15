function wstats = de_StatsHUActivations(mss, dset)

% Note: not tested after bias input permanently added

  wstats = cell(size(mss));
  
  for i=1:length(mss)
    wstats{i} = zeros(size(mss{i}));
    
    for j=1:length(mss{i})
      model = de_LoadProps(mss{i}(j), 'ac', 'Weights');
      nPix = prod(model.nInput);
      
      wInputToHidden  = model.ac.Weights( (nPix+2):(nPix+1+model.nHidden), 1:nPix+1);
      wHiddenToOutput = model.ac.Weights( (end-nPix+2):end, (nPix+2):(nPix+1+model.nHidden))';
      [wstats{i}(j),b] = corr(wInputToHidden(:),wHiddenToOutput(:));
      [wstats{i}(j)]  = reshape(wInputToHidden, [1, prod(size(wInputToHidden))]) * reshape(wHiddenToOutput, [prod(size(wHiddenToOutput)), 1]);

      % Now, clamp each hidden unit, and produce output
    end;
    
    fprintf('\t');
  end;
  
  x = [wstats{1};wstats{2}];
  g = cat(1, ...
          repmat({'RH'},size(wstats{1})), ...
          repmat({'LH'},size(wstats{2})));
  [x,y] = anova1(x, g)
  
  mean(wstats{1})
  mean(wstats{2})
  keyboard
  