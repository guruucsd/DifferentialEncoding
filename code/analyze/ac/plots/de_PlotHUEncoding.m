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
  function de_PlotHUEncoding_2D(huenc, mupos, imgsize, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]

    nImages = size(huenc,2);

    [nRows,nCols] = guru_optSubplots(nImages);
    cx            = [-max(abs(huenc(:))) max(abs(huenc(:)))]; %make sure it's symmetric, so zero is consistent across plots

    for ii=1:nImages
        [img] = enc2img(huenc(:,ii), mupos, imgsize);

        % Plot the connectivity pattern
        subplot(nRows, nCols, ii);
        colormap(gray);
        imagesc(img);
        caxis(cx);

        set(gca,'ytick',[], 'xtick', []);
%        hold on;
%        plot(mupos(:,1), mupos(:,2), '*g');
    end;

    mfe_suptitle(t);


    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUEncoding_Instance2D(model, huenc)
  %2d plot
    fig = de_NewFig('hu-encoding-inst', 'hu', model.nHidden, model.nInput);

    [~,mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);

    de_PlotHUEncoding_2D( huenc, mupos, model.nInput, sprintf('Instance (model) hu encoding plot, o=%4.1f', model.sigma));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUEncoding_Average2D(models, huencs)
  %2d plot
    fig = de_NewFig('hu-encoding-avg', 'hu', models(1).nHidden, models(1).nInput);

    [~,mupos] = de_connector_positions(models(1).nInput, models(1).nHidden/models(1).hpl);

    sz     = size(huencs);
    huencs = reshape(mean(huencs, 1), sz(2:end));

    de_PlotHUEncoding_2D(huencs, mupos, models(1).nInput, sprintf('Average (over models) hu encoding plot, o=%4.1f', models(1).sigma));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [img,imgsize] = enc2img(enc, mupos, imgsize)
      
    scalefact = imgsize(1)/imgsize(2);
    hpl = size(mupos,1); %hidden units per hidden layer
    xsz = sqrt(hpl/scalefact);
    ysz = xsz * scalefact;
    sz  = round([ysz xsz]);
    if (prod(sz)==hpl)
        mupos(:,1) = round(mupos(:,1)/imgsize(1)*ysz);
        mupos(:,2) = round(mupos(:,2)/imgsize(2)*xsz);
        imgsize = sz;
    else
        mupos = round(mupos);
    end;
          
    img = zeros(imgsize);
    mpi = sub2ind(imgsize,mupos(:,1),mupos(:,2));
    img(mpi) = enc;
