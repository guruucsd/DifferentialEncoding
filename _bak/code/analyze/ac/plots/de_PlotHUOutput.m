function [fig] = de_PlotHUOutput(models, huouts)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

  % Plot 1: show trend of encoding error, according to type (Reza's plots)
  %   This plot will show outliers as spikes.
  % Create old-style info

  fig        = de_NewFig('dummy');
  fig(end+1) = de_PlotHUOutput_Instance2D(models(1), squeeze(huouts(1,:,:)));
  fig(end+1) = de_PlotHUOutput_Average2D (models, huouts);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotHUOutput_2D(imgs, mupos, cx, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]
  
    nHidden = size(imgs,1);
    %inPix = [size(imgs,2) size(imgs,3)];
    
    [nRows,nCols] = guru_optSubplots(nHidden);
    
    for hu=1:nHidden
         
        % Plot the connectivity pattern
        subplot(nRows, nCols, hu);
        colormap(gray);

        imagesc(squeeze(imgs(hu,:,:)));
        caxis(cx);
        set(gca,'ytick',[], 'xtick', []);
        
        %plot(cx(i), cy(i), '*g');
    end;
    
    mfe_suptitle(t);
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUOutput_Instance2D(model, huouts)
  %2d plot
    fig = de_NewFig('hu-output-inst', 'hu', model.nHidden, model.nInput);
        
    [~,~,mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);

    de_PlotHUOutput_2D( huouts, mupos, sprintf('Instance hu output plot, o=%4.1f', model.sigma));
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUOutput_Average2D(models, huouts)
  %2d plot
    fig = de_NewFig('hu-output-inst', 'hu', models(1).nHidden, models(1).nInput);
        
    [~,~,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);

    de_PlotHUOutput_2D( squeeze(mean(huouts, 1)), mupos, sprintf('Instance hu output plot, o=%4.1f', models(1).sigma));
    
    