function [sta] = de_StatsSTA(mss, nImages)
%function [sta] = de_StatsSTA(mss,nImages)
%
% For each hidden unit across each model, compute the spike-triggered average,
%   using white noise images within the statistics of the training dataset
%   (same mean and std).
%
%   Since we don't have spikes, then we must compute the weighted sum of activations:
%
% sta = (1/sum(act)) * sum_{img}( act(img) * img )

  if (isempty(mss) || isempty(mss{1}))
      sta = [];
      return;
  end;

  if (~exist('nImages','var')), nImages = 500; end;

  mSets = mss{1}(1);

  % Create the random images
  nPix = prod(mSets.nInput);
  train = mSets.data.train.X(1:nPix,:);
  images = mean(train(:)) + std(train(:))*(rand([nPix+1 nImages])-0.5);
  images(end,:) = mSets.data.train.bias;
  
  % Measure the hidden unit output and compute each hidden unit's "preferred" image
  sta = cell(size(mss));
  for si=1:length(mss)
    sta{si} = zeros(length(mss{si}), nPix, mSets.nHidden); %

    for mi=1:length(mss{si})
      fprintf( '%d ', mi);

      model = mss{si}(mi);

      if (~isfield(model.ac, 'Weights'))
          model            = de_LoadProps(model, 'ac', 'Weights');
      end;
      [~,~,huacts]    = guru_nnExec(model.ac, images, images(1:end-1,:));           % Produce hidden unit activations
      sta{si}(mi,:,:) = (images(1:end-1,:) * huacts') ./ repmat(sum(huacts',1), [nPix 1]);
    end;
    fprintf('\t');
  end;
