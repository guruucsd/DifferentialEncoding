function dset = de_NormalizeDataset(dset, mSets)
%function dset = de_NormalizeDataset(dset, mSets)
%
%  Change a dataset, based on some particular model settings.
%
%  dset.X should come in with values in range [0 1]
%  mSets contains the options for the dataset

  if (~isfield(mSets.ac, 'minmax') || isempty(mSets.ac.minmax))

	  switch (mSets.ac.XferFn(end)) % either a single number, or a vector with output nodes at the end
		  case {4,6}, mSets.ac.minmax    = [-1 1]; %note that 6 goes to 1.71, but the input/output should be
												   % in the [-1 1] range as well
		  case {2,3}, mSets.ac.minmax    = [0 1];
		  case {5}, mSets.ac.minmax = 0.5*[-1 1];
		  case {1}, mSets.ac.minmax = [];
		  otherwise, error('unknown transfer function');
	  end;
  end;

  %%%%%%%%%%%%%%%%%%%%%%%
  % Autoencoder normalization
  %%%%%%%%%%%%%%%%%%%%%%%

  % Z-score: pixel-by-pixel
  if (isfield(mSets.ac, 'zscore_across') && mSets.ac.zscore_across)

      stdTr             = std(dset.X,[],2);                                    % std
      dset.X(stdTr>0,:) = 0.1*dset.X(stdTr>0,:) ./ repmat(stdTr(stdTr>0), [1 size(dset.X,2)]);

      dset.X            = dset.X - repmat(mean(dset.X,2), [1 size(dset.X,2)]); %zero-mean

      if (~isempty(mSets.ac.minmax))
          dset.X = mean(mSets.ac.minmax) + dset.X;
      end;

  % Z-score: across all images and pixels at once
  elseif (isfield(mSets.ac, 'zscore'))
    if (islogical(mSets.ac.zscore)), % will produce mean 0, std 0.1 data at each pixel
      zs.delta_mean = mean(dset.X, 1);
      zs.delta_std  = 0.1 ./ std(dset.X);
    elseif isnumeric(mSets.ac.zscore)
      zs.delta_mean = mean(dset.X);
      zs.delta_std  = mSets.ac.zscore ./ std(dset.X, [], 1);
    elseif isstruct(mSets.ac.zscore)
      zs = mSets.ac.zscore;
    else
      error('Unrecognized type for zscore property.');
    end;

    dset.X  = (dset.X - repmat(zs.delta_mean, [size(dset.X,1) 1])) .* repmat(zs.delta_std, [size(dset.X,1) 1]);
    dset.zs = zs;


  % Prepare to put into minmax range by subtracting out midpoint of original [0 1] range
  elseif (~isempty(mSets.ac.minmax))
    if (isfield(dset,'minmax')), dset.X = dset.X - diff(dset.minmax)/2;
    else,                        dset.X = dset.X - 0.5;
    end;
  end;

  % Now put into the defined range
  if (~isempty(mSets.ac.minmax))

      % Normalize inputs based on transfer function
      dset.X = dset.X + mean(mSets.ac.minmax);

  end;

  % Haaaaaack....
  if (isfield(mSets.ac, 'absmean'))
    dset.X = dset.X*(mSets.ac.absmean/mean(abs(dset.X(:))));
  end;

  % Bias has not been added, so can just examine values
  if (ismember(2, mSets.ac.debug))
      fprintf('[%s] min/max=[%4.3e %4.3e]; mean=%4.3e std=%4.3e\n', ...
              dset.name, min(dset.X(:)), max(dset.X(:)),...
                         mean(dset.X(:)), std(dset.X(:)) );
  end;

  % Add a bias to all inputs
  %
  % NOTE: only do if "useBias" field is defined
  %
  if (isfield(mSets.ac, 'useBias'))
      if (~isfield(dset, 'bias')), dset.bias = mean(abs(dset.X(:))); end;
      dset.X(end+1,:) = dset.bias*mSets.ac.useBias;
  end;


  % Validate train; screw you, test!
  guru_assert(~any(isnan(dset.X(:))), 'nan X-values');
  if (~isempty(mSets.ac.minmax))
      guru_assert(~any(dset.X(:)<mSets.ac.minmax(1)), sprintf('X-values outside [%d %d] range', mSets.ac.minmax)); % We won't be able to replicate
      guru_assert(~any(dset.X(:)>mSets.ac.minmax(2)), sprintf('X-values outside [%d %d] range', mSets.ac.minmax)); %   these values with the autoencoder
  end;



  %%%%%%%%%%%%%%%%%%%%%%%
  % Perceptron normalization
  %%%%%%%%%%%%%%%%%%%%%%%

  if (isfield(dset,'T') && isfield(mSets, 'p'))

      if (~isfield(mSets.p, 'minmax'))
          switch (mSets.p.XferFn(end)) % either a single number, or a vector with output nodes at the end
              case {4,6}, mSets.p.minmax    = [-1 1];
              case {1}
              	mSets.p.minmax = [0 1];
  		        rand_idx = randi(numel(dset.T), 1000, 1);
				if length(unique(dset.T(rand_idx))) <= 2
				  mSets.p.minmax = [-1 1];
				end;
              otherwise,  mSets.p.minmax    = [0 1];
          end;
      end;

      % Normalize expected outputs based on classifier transfer function
      dset.T = dset.T - 0.5;
      dset.T = diff(mSets.p.minmax)*dset.T + mean(mSets.p.minmax);

      % Duplicate the outputs, for robust training
      if (isfield(mSets.p, 'ndupes'))
          dset.T = repmat(dset.T, [mSets.p.ndupes 1]);
      end;

      % validate dset
%      guru_assert(~any(isnan(dset.T(:))), 'nan T-values');
%      guru_assert(~any(dset.T(:)<mSets.p.minmax(1)), sprintf('T-values outside [%d %d] range', mSets.p.minmax));
%      guru_assert(~any(dset.T(:)>mSets.p.minmax(2)), sprintf('T-values outside [%d %d] range', mSets.p.minmax));
  end;
