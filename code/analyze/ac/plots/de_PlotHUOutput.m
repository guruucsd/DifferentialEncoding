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
  fig(end+1) = de_PlotHUOutput_Instance2D(models(1), reshape(huouts(1,:,:,:), [size(huouts,2) size(huouts,3) size(huouts,4)]));
  fig(end+1) = de_PlotHUOutput_Average2D (models, huouts);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotHUOutput_2D(imgs, mupos, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]

    nImages = size(imgs,1);

    [nRows,nCols] = guru_optSubplots(nImages);
    cx = [-max(abs(imgs(:))) max(abs(imgs(:)))]; %make sure it's symmetric, so zero is consistent across plots

    selectedHUs = de_SelectHUs();
    huis        = mod(selectedHUs-1,size(mupos,1))+1; % get mupos index

    for ii=1:nImages

        % Plot the connectivity pattern
        subplot(nRows, nCols, ii);
        colormap(gray);

        imagesc(squeeze(imgs(ii,:,:)));
        caxis(cx);
        set(gca,'ytick',[], 'xtick', []);

        hold on;
        plot(mupos(huis(ii),2), mupos(huis(ii),1), '*g');
    end;

    mfe_suptitle(t);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUOutput_Instance2D(model, huouts)
  %2d plot
    fig = de_NewFig('hu-output-inst', 'hu', model.nHidden, model.nInput);

    [~,mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);

    de_PlotHUOutput_2D( huouts, mupos, sprintf('Instance (model) stimulated hu output, o=%4.1f', model.sigma));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUOutput_Average2D(models, huouts)
  % Average over MODELS, not images.

    fig = de_NewFig('hu-output-avg', 'hu', models(1).nHidden, models(1).nInput);

    [~,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);

    de_PlotHUOutput_2D( reshape(mean(huouts, 1), [size(huouts,2) size(huouts,3) size(huouts,4)]), mupos, sprintf('Average (over models) stimulated hu output, o=%4.1f', models(1).sigma));

