function mSets = de_NormalizeDataset(mSets)

  % Data files have data going from 0 to 1.  
  % Make sure to match training sessions with data settings




  switch (mSets.ac.XferFn)
      case {4,6}, mSets.ac.minmax    = [-1 1]; %note that 6 goes to 1.71, but the input/output should be 
                                               % in the [-1 1] range as well
      otherwise,  mSets.ac.minmax    = [0 1];
  end;
  
  % Alias for convenience
  train.X = mSets.data.train.X;
  test.X  = mSets.data.test.X;

  % Z-score 
  if (false && Sets.ac.zscore_across)
      
      train.X = train.X - repmat(mean(train.X,2), [1 size(train.X,2)]);
      stdTr   = std(train.X,[],2);
      train.X(stdTr>0,:) = repmat(train.X(stdTr>0), [1 size(train.X,2)]);

      test.X  = test.X  - repmat(mean(test.X,2),  [1 size(test.X,2)]);
      stdTs   = std(test.X,[],2);
      test.X(stdTs>0,:)  = repmat(test.X(stdTr>0),  [1 size(test.X,2)]);

      % Now normalize to expected range
      % Scale to proper range
      train.X = train.X ./ ( (max(train.X(:))-min(train.X(:))) / diff(mSets.ac.minmax) );
      test.X  = test.X  ./ ( (max(test.X (:))-min(test.X (:))) / diff(mSets.ac.minmax) );
      
      % Then shift to be centered in range of the sigmoid
      train.X = train.X - min(train.X(:)) + mSets.ac.minmax(1);
      test.X  = test.X  - min(test.X(:))  + mSets.ac.minmax(1);

  elseif (mSets.ac.zscore)
    train.X = (train.X - repmat(mean(train.X), [size(train.X,1) 1])) ./ repmat(std(train.X), [size(train.X,1) 1]);
    test.X  = (test.X  - repmat(mean(test.X),  [size(test.X,1)  1])) ./ repmat(std(test.X),  [size(test.X,1)  1]);

    train.X = mean(mSets.ac.minmax) + train.X;
    test.X  = mean(mSets.ac.minmax) + test.X;

  else
      train.X = train.X - 0.5;
      test.X  = test.X  - 0.5;
      
      
      % Normalize inputs based on transfer function 
      train.X = diff(mSets.ac.minmax)*(train.X) + mean(mSets.ac.minmax);
      test.X  = diff(mSets.ac.minmax)*(test.X) + mean(mSets.ac.minmax);
  end;
  
  % Validate train; screw you, test!
  guru_assert(~any(isnan(mSets.data.train.X(:))), 'nan X-values');
  guru_assert(mSets.ac.zscore || ~any(train.X(:)<mSets.ac.minmax(1)), sprintf('X-values outside [%d %d] range', mSets.ac.minmax));
  guru_assert(mSets.ac.zscore || ~any(train.X(:)>mSets.ac.minmax(2)), sprintf('X-values outside [%d %d] range', mSets.ac.minmax));
  
  % Re-assign result
  mSets.data.train.X = train.X;
  mSets.data.test.X  = test.X;
  
  
  
  if (isfield(mSets, 'p'))
      switch (mSets.p.XferFn)
          case {4,6}, mSets.p.minmax    = [-1 1];
          otherwise,  mSets.p.minmax    = [0 1];
      end;
  
      % Alias for convenience
      train.T = mSets.data.train.T;
      test.T  = mSets.data.test.T;
    
      if (mSets.p.zscore)
          error('z-scoring on the classifier output NYI');
        
      else
          train.T = train.T - 0.5;
          test.T  = test.T  - 0.5;
          
          % Normalize expected outputs based on classifier transfer function
          if (isfield(mSets, 'p'))
              train.T = diff(mSets.p.minmax)*train.T + mean(mSets.p.minmax);
              test.T  = diff(mSets.p.minmax)*test.T  + mean(mSets.p.minmax);
          end;
      end;
      
      % validate train; screw you, test!
      guru_assert(~any(isnan(train.T(:)) & ~isnan(mSets.data.train.T(:))), 'nan T-values');
      guru_assert(~any(train.T(:)<mSets.p.minmax(1)), sprintf('T-values outside [%d %d] range', mSets.p.minmax));
      guru_assert(~any(train.T(:)>mSets.p.minmax(2)), sprintf('T-values outside [%d %d] range', mSets.p.minmax));
      
      % Re-assign result
      mSets.data.train.T = train.T;
      mSets.data.test.T  = test.T;
  end;    
  