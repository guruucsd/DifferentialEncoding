function [fig] = de_PlotConnectivity_Avg(mSets, mss)
%function [fig] = de_PlotConnectivity(models)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

 
  nDims   = length(mSets.nInput);
  if (nDims~=2), fig = []; return; end;
  
  %    
  fig.name   = 'connect-2Dto1D';
  fig.handle = figure;
  fig.size   = [10 12];
  
  % Should check for 1D case
  [nRows,nCols] = guru_optSubplots(length(mss));
  
  for i=1:length(mss)
    models=mss{i};
    curves = [];
    
    % Pull out connections
    [~,mupos] = de_connector2D_positions(models(1).nInput, models(1).nHidden/models(1).hpl);
    models = de_LoadProps(models, 'ac', 'Weights');

    inPix = prod(models(1).nInput);
    c2 = zeros([models(1).nHidden models(1).nInput]);

    for j=1:length(models)
      c     = full(models(j).ac.Weights(inPix+1:models(j).nHidden+models(j).nHidden, 1:inPix) ~= 0);
      c     = reshape(c, [models(j).nHidden models(j).nInput]);
      c2    = c2 + c / length(models);
    end;

%    for j=1:length(models)
%      c     = full(models(j).ac.Weights(inPix+1:models(j).nHidden+models(j).nHidden, 1:inPix) ~= 0);
%      c2    = c2 + c / length(models);
%    end;

    % Move from 2D to 1D
    pt = round(size(c2,1)/2); %hidden unit
    
    layer = squeeze(c2(pt,:,:));
    
    subplot(nRows,nCols,i);
    imshow(layer); hold on; 
%    plot(mupos(pt,1), mupos(pt,2), 'g*', 'LineWidth', 5.0, 'MarkerSize', 5.0)
    
    xlabel('pixel');
    ylabel('P(connection)');
    yl=get(gca,'ylim');
%    legend({sprintf('\\sigma=%3.1f', models(1).sigma), 'Expected Gaussian'}, 'Location', 'NorthOutside');
    
  end;
