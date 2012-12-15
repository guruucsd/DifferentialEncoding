function [fig] = de_PlotOutputImageFFTs(models, dset)
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

  nDims   = length(models{1}(1).nInput);

  guru_assert(length(models) == 2);
  
  switch (nDims)
    case 2, [fig]        = de_PlotOutputImageFFTAvg_Average2D(models, dset);
  end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotOutputImageFFTAvg_2D( ampl, obj, t)
  %2d plot

    % Plot the connectivity pattern
    imagesc(ampl);
    hold on;
    set(gca, 'xtick',[],'ytick',[]);
  
    colorbar('EastOutside');;
    mfe_suptitle(t);
      
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [fig] = de_PlotOutputImageFFTAvg_Average2D(allmodels, obj)
  %2d plot
    fig = de_NewFig('image-fft-avg-diff', 'images', dset.X);

    %models = de_LoadProps(models, 'ac', 'Weights');
    signs = [1 -1];
    nImages = size(obj.X,2);
    ffts     = zeros(allmodels{1}(1).nInput);
    
    for w=1:length(allmodels)
      models = allmodels{w};
      
      for i=1:length(models)
        model = de_LoadProps(models(i), 'ac', 'Weights');
        [imgs]   = guru_nnExec(model.ac, obj.X, obj.X);

        for j=1:nImages
          img = reshape(imgs(:,j), model.nInput);
          img = img - mean(mean(img));
          cfft = fft2(img);
          ffts = ffts + signs(w)*(cfft.*conj(cfft)) / (length(models)*length(allmodels));
        end;
      end;
      
    end;
    
    de_PlotOutputImageFFTAvg_2D( ...
        ffts,...
        obj, ...
        sprintf('Average image FFT plot') ...
      );
