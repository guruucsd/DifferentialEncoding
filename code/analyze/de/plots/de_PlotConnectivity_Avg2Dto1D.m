function fig = de_PlotConnectivity_Avg2Dto1D(mSets, mss)
%
  
  %    
  fig.name   = 'connect-2Dto1D';
  fig.handle = figure;
  fig.size   = [10 12];
  
  % Should check for 1D case
  [nRows,nCols] = guru_optSubplots(length(mss));
  
  for i=1:length(mss)
    models=mss{i};
    curves = [];

    subplot(nRows,nCols,i);
    
    % Pull out connections
    [junk, hpl, mu] = de_connector(models(1));
    models = de_LoadProps(models, 'ac', 'Weights');

    inPix = prod(models(1).nInput);
    c2 = zeros([models(1).nHidden models(1).nInput]);

    for j=1:length(models)
      c     = (models(j).ac.Weights ~= 0);
      c2    = c2 + reshape(full(c((inPix+1):(inPix+models(j).nHidden),1:inPix)), [models(j).nHidden models(j).nInput]) / length(models);
    end;

    % Move from 2D to 1D
    layer = squeeze(c2(10,:,:));
    [junk, hpl, mu] = de_connector(models(1));
    [cy,cx] = find(mu); center=cy(10);
    curves = sum(layer,2)';
  
    % Gaussian and norm'd
    curves(end+1,:) = normpdf(1:size(curves,2), center, models(1).sigma);
    curves(1,:)     = curves(1,:)*sum(curves(end,:))/sum(curves(1,:));
    
    plot(curves', 'LineWidth', 2.0);
    xlabel('pixel');
    ylabel('P(connection)');
    yl=get(gca,'ylim');
    set(gca,'xlim',[1 size(curves,2)]);
    set(gca,'ylim',[0 0.1]);
    legend({sprintf('\\sigma=%3.1f', models(1).sigma), 'Expected Gaussian'}, 'Location', 'NorthOutside');
  end;

