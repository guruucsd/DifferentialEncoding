function [figs] = de_PlotConnectivity(mSets, mss)
%function [figs] = de_PlotConnectivity(models)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

 
  nDims   = length(mSets.nInput);
  if (nDims~=2), error('Connectivity plot NYI for non-2D case'); end;
  
  figs          = de_NewFig('dummy');
  [nRows,nCols] = guru_optSubplots(length(mss));
  
  %    
  figs(end+1) = de_NewFig('connect-avg');
  figs(end+1) = de_NewFig('connect-inst');
  figs(end+1) = de_NewFig('connect-2Dto1D');
  
  
  layer = zeros([length(mss) mSets.nInput]);
  
  for ii=1:length(mss)
    models=mss{ii};
    
    % Pull out weights
    models = de_LoadProps(models, 'ac', 'Weights');

    % Find best hidden unit to analyze
    [mu,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);
    [cy,cx] = find(mu);
    [~,pt] = min( sqrt( (cy-size(mu,1)/2).^2 + (cx-size(mu,2)/2).^2 ) );
    
    % Average connectivity
    figure(figs(1).handle); subplot(nRows,nCols,ii);
    [pt, layer(ii,:,:)] = ...
    de_PlotConnectivity_Avg   (figs(1), models, pt, mupos);
    
    % Instance connectivity
    figure(figs(2).handle); subplot(nRows,nCols,ii);
    de_PlotConnectivity_Avg   (figs(2), models(1), pt, mupos);

    % Reduction to a 1D view
    figure(figs(3).handle); subplot(nRows,nCols,ii);
    de_PlotConnectivity_2Dto1D(figs(3), models(1).sigma, cy(pt), squeeze(layer(ii,:,:)));
    
  end;

  % Plot difference
  figs(end+1) = de_NewFig('connect-diff');

    %% Plot 1: show top-down view
    imagesc(squeeze(layer(1,:,:)-layer(end,:,:)), [-0.3 0.3]); hold on; 
    colorbar;
    set(gca, 'xtick', [], 'ytick', []);
    
    plot(mupos(pt,2), mupos(pt,1), 'g*', 'LineWidth', 5.0, 'MarkerSize', 5.0)
    
    xlabel('pixel');
    ylabel('P(connection)');
    yl=get(gca,'ylim');
%    legend({sprintf('\\sigma=%3.1f', models.sigma), 'Expected Gaussian'}, 'Location', 'NorthOutside');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pt, layer]  = de_PlotConnectivity_Avg(fig, models, pt, mupos)

    % Total # pixels
    inPix = prod(models(1).nInput);
    
    nHiddenPerLayer = models(1).nHidden/models(1).hpl;
    
    layer = zeros(models(1).nInput);
    for j=1:length(models)
      % Actual connections
      c     = full(models(j).ac.Weights((inPix+1)+[1:models(j).nHidden], 1:inPix) ~= 0);
      c     = reshape(c, [models(j).nHidden models(j).nInput]);
      
      % Pull connections from all hidden units with this same locust
      ptIdx = pt + nHiddenPerLayer*[0:models(1).hpl-1];

      % Average connections
      layer = layer + squeeze(mean(c(ptIdx,:,:),1)) / (length(models)*models(1).hpl);
    end;
    clear('c');


    %% Plot 1: show top-down view
    imagesc(layer, [0 0.3]); hold on; 
    set(gca, 'xtick', [], 'ytick', []);
    
    plot(mupos(pt,2), mupos(pt,1), 'g*', 'LineWidth', 5.0, 'MarkerSize', 5.0)
    
    xlabel('pixel');
    ylabel('P(connection)');
    yl=get(gca,'ylim');
%    legend({sprintf('\\sigma=%3.1f', models.sigma), 'Expected Gaussian'}, 'Location', 'NorthOutside');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function de_PlotConnectivity_2Dto1D(fig, sigma, center, layer)

    

    %% Plot 2: show average side view
    %center=cy(pt);

    curves = sum(layer,2)';
  
    % Gaussian and norm'd
    curves(end+1,:) = normpdf(1:size(curves,2), center, sigma);
    curves(1,:)     = curves(1,:)*sum(curves(end,:))/sum(curves(1,:)); % normalize curve
    
    plot(curves', 'LineWidth', 2.0);
    xlabel('pixel');
    ylabel('P(connection)');
    yl=get(gca,'ylim');
    set(gca,'xlim',[1 size(curves,2)]);
    set(gca,'ylim',[0 0.3]);
    legend({sprintf('\\sigma=%3.1f', sigma), 'Expected Gaussian'}, 'Location', 'NorthOutside');
    
    
    
% old code
%    ptsa = find( abs(cy-size(mu,1)/2) < 5 );
%    ptsb = find( abs(cx-size(mu,2)/2) < 4 );
%    pts  = intersect(ptsa, ptsb);
%    if (any(pts))
      %cy(pts), cx(pts)
      %pt = pts( floor(length(pts)/2) ); %midpoint
    %else
    %  pt = floor(size(cavg,1)/hpl/2); %hidden unit (attempting to be centered)
    %end;

