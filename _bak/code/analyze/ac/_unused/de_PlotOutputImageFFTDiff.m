function [fig] = de_PlotOutputImageFFTDiff(ffts, dset)
%function [fig] = de_PlotOutputImageFFTDiff(ffts, dset)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

  nDims   = length(dset.nInput);

  guru_assert(length(ffts) == 2);
  
  switch (nDims)
    case 2, [fig] = de_PlotOutputImageFFTDiff_Average2D(ffts, dset);
  end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotOutputImageFFTDiff_2D( ampl, obj, t)
  %2d plot

    nImages = size(ampl,1);
    [nRows,nCols] = guru_optSubplots(nImages);
    
    for i=1:nImages
      cfft = fftshift(squeeze(ampl(i,:,:)));
      
      % Plot the connectivity pattern
      subplot(nRows, nCols, i);
      imagesc(cfft);
      hold on;

      set(gca, 'xtick',[],'ytick',[]);
      
      if (nImages == length(obj.XLAB))
        xlabel(sprintf('%s: (%s)', obj.XLAB{i}, obj.TLAB{i}));
      end;
    end;
    
    %
    hold on;
    mfe_suptitle([t ' (log scale)']);
      
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [fig] = de_PlotOutputImageFFTDiff_Average2D(ffts, dset)
  %2d plot
    fig = de_NewFig('images-fft-diff-avg', 'images', dset);
    
    diffs = squeeze(mean((ffts{1})-(ffts{2}),1));
    
    % Plot each image fft difference
    de_PlotOutputImageFFTDiff_2D( ...
        diffs,...
        dset, ...
        sprintf('FFT difference plot, over all models') ...
      );
      
    fig(2) = de_NewFig('images-fft-diff-avg', 'images', dset);
    % Plot each image fft difference
    de_PlotOutputImageFFTDiff_2D( ...
        mean(diffs,1),...
        dset, ...
        sprintf('FFT difference plot, over all models and images') ...
      );
