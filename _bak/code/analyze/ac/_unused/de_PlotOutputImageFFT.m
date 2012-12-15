function [fig] = de_PlotOutputImageFFTs(sigma, ffts, dset)
%function [fig] = de_PlotOutputImageFFTs(models)
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
  nDims   = length(dset.nInput);

  switch (nDims)
    case 1, [fig] = de_PlotOutputImageFFTs_Instance1D(sigma, squeeze(ffts(1,:,:,:)), dset);
    case 2, [fig] = de_PlotOutputImageFFTs_Instance2D(sigma, squeeze(ffts(1,:,:,:)), dset);
  end;

  switch (nDims)
    case 1, fig = [fig de_PlotOutputImageFFTs_Average1D(sigma, ffts, dset)];
    case 2, fig = [fig de_PlotOutputImageFFTs_Average2D(sigma, ffts, dset)];
  end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotOutputImageFFTs_2D( ampl, obj, t)
  %2d plot

    nImages = size(ampl,1);
    [nRows,nCols] = guru_optSubplots(nImages);
    
    for i=1:nImages
      ampl(i,1,1) = 0;
      cfft = log(fftshift(squeeze(ampl(i,:,:))));
      
      % Plot the connectivity pattern
      subplot(nRows, nCols, i);
      imagesc(cfft);
      hold on;

      set(gca, 'xtick',[],'ytick',[]);
      
      if (nImages==length(obj.XLAB))
        xlabel(sprintf('%s: (%s)', obj.XLAB{i}, obj.TLAB{i}));
      end;
    end;
    
    %
    hold on;
    mfe_suptitle([t ' (log scale)']);
      
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImageFFTs_Instance2D(sigma, ffts, dset)
  %2d plot
    fig = de_NewFig('image-fft-inst', 'images', dset);
        
    % Plot each image separately
    de_PlotOutputImageFFTs_2D( ...
        ffts,...
        dset, ...
        sprintf('Instance image FFT plot, o=%4.1f', sigma) ...
      );
      
   % Plot average over images
   fig(2) = de_NewFig('image-fft-instavg', 'images', dset);
   means = mean(ffts,1);
   de_PlotOutputImageFFTs_2D( ...
       means,...
       dset, ...
       sprintf('Mean Instance FFT over all images, o=%4.1f', sigma) ...
     );    
     
     
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [fig] = de_PlotOutputImageFFTs_Average2D(sigma, ffts, dset)
  %2d plot
    fig = de_NewFig('image-fft-avg', 'images', dset);

    % Average over models
    ffts = squeeze(mean(ffts,1));
    
    % Plot each image individually
    de_PlotOutputImageFFTs_2D( ...
        ffts,...
        dset, ...
        sprintf('Average image FFT plot, o=%4.1f', sigma) ...
      );

   % Plot average over images
   fig(2) = de_NewFig('image-fft-avgavg', 'images', dset);
   means = mean(ffts,1);
   de_PlotOutputImageFFTs_2D( ...
       means,...
       dset, ...
       sprintf('Mean Average FFT over all images, o=%4.1f', sigma) ...
     );