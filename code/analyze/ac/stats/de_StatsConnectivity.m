function [stats] = de_StatsConnectivity(mss)
%function [stats] = de_StatsConnectivity(mSets,mss)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots
  

  if isempty(mss)
      stats = [];
      return;
  end;
  
  mSets = mss{1}(1);
 
  nDims   = length(mSets.nInput);
  if (nDims~=2), error('Connectivity analysis NYI for non-2D case'); end;

  stats.mean2D = zeros([length(mss) mSets.nInput]);
  stats.inst1D = zeros([length(mss) mSets.nInput]);
  stats.mean1D = zeros([length(mss) mSets.nInput(1)]);

  for ii=1:length(mss)
    % Pull out weights
    models = de_LoadProps(mss{ii}, 'ac', 'Weights');

    inPix = prod(models(1).nInput);
    nHiddenPerLayer = models(1).nHidden/models(1).hpl;


    % Get all hidden unit positions, and 'center' them
    [mu,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);
    [cy,cx] = find(mu);
    [~,pt] = min( sqrt( (cy-size(mu,1)/2).^2 + (cx-size(mu,2)/2).^2 ) );

    % Average connections
    layer = zeros(models(1).nInput);
    for mi=1:length(models)
      % Actual connections
      c     = full(models(mi).ac.Weights((inPix+1)+[1:models(mi).nHidden], 1:inPix) ~= 0);
      c     = reshape(c, [models(mi).nHidden models(mi).nInput]);
      
      % Pull connections from all hidden units with this same locust
      ptIdx = pt + nHiddenPerLayer*[0:models(1).hpl-1];

      % Average connections
      layer = layer + squeeze(mean(c(ptIdx,:,:),1)) / (length(models)*models(1).hpl);

      % save off the 1D version
      if (mi==1)
        stats.inst1D(ii,:,:) = layer*length(models); 
      end;
    end;

    % Save off the 2D version
    stats.mean2D(ii,:,:) = layer;


    % Reduction to a 1D view
    stats.mean1D(ii,:) = sum(layer,2)'./sum(layer(:));
    %curves(end+1,:) = normpdf(1:size(curves,2), center, sigma);
    %curves(1,:)     = curves(1,:)*sum(curves(end,:))/sum(curves(1,:)); % normalize curve
    %curves(1,:)     = curves(1,:)/sum(curves(1,:)); % normalize curve
        
  end;


