function [fig] = de_PlotHUEncoding(models, huencs)
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
  fig(end+1) = de_PlotHUEncoding_Instance2D(models(1), squeeze(huencs(1,:,:)));
  fig(end+1) = de_PlotHUEncoding_Average2D (models, huencs);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotHUEncoding_2D(imgs, mupos, cx, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]
  
    nHidden = size(imgs,1);
    inPix = [size(imgs,2) size(imgs,3)];
    
    [nRows,nCols] = guru_optSubplots(nHidden);
    
    for hu=1:nHidden
         
        % Plot the connectivity pattern
        subplot(nRows, nCols, hu);
        colormap(gray);
        %keyboard
        imagesc(squeeze(imgs(hu,:,:)));
        caxis(cx);
        set(gca,'ytick',[], 'xtick', []);
        %hold on;
        %plot(cx(i), cy(i), '*g');
    end;
    
    mfe_suptitle(t);
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUEncoding_Instance2D(model, huenc)
  %2d plot
    fig = de_NewFig('hu-encoding-inst', 'hu', model.nHidden, model.nInput);
        
    [~,mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);

    img = enc2img(huenc, mupos, model.nInput);
    de_PlotHUEncoding_2D( img, mupos, sprintf('Instance hu encoding plot, o=%4.1f', model.sigma));
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUEncoding_Average2D(models, huencs)
  %2d plot
    fig = de_NewFig('hu-encoding-inst', 'hu', models(1).nHidden, models(1).nInput);
        
    [~,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);

    huencs = squeeze(mean(huencs, 1));
    
    imgs = zeros([size(huencs,1) models.nInput]);
    for hu=1:size(huencs,1)
        imgs(hu,:,:) = enc2img(huenc, mupos, model.nInput);
    end;
    
    de_PlotHUEncoding_2D(imgs, mupos, sprintf('Instance hu encoding plot, o=%4.1f', models(1).sigma));
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function img = enc2img(enc, mupos, imgsize)
    img = zeros(imgsize);
    img(mupos) = enc;
    