function [fig] = de_PlotOutputImages(models, dset)
%function [fig] = de_PlotOutputImages(models,data)
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

  nDims   = length(models(1).nInput);

  switch (nDims)
%      case 1, fig = de_PlotOutputImages_Instance1D(models{i}(1), hpl, mu);
    case 2, fig = de_PlotOutputImages_Instance2D(models(1), dset);
  end;

  switch (nDims)
%      case 1, fig(2) = de_PlotOutputImages_Average1D(models{i}, hpl, mu);
      case 2, fig(end+1) = de_PlotOutputImages_Average2D(models, dset);
  end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotOutputImages_2D( o, obj, t)
  %2d plot
  
    plotNum = 1;
    nImages = size(o,3);
    [nRows,nCols] = guru_optSubplots(nImages);
    
    for i=1:nImages
      img = squeeze(o(:,:,i));
      
      % Plot the connectivity pattern
      subplot(nRows, nCols, i);
      colormap(gray);
      imagesc(img);
      hold on;

      set(gca, 'xtick',[],'ytick',[]);
      xlabel(sprintf('%s: (%s)', obj.XLAB{i}, obj.TLAB{i}));
    end;
    
    %
    hold on;
    mfe_suptitle(t);
      
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_Instance2D(model, dset)
  %2d plot
    fig = guru_newFig('images-inst', 'images', dset);
    
    model = de_LoadProps(model, 'ac', 'Weights');
    
    [o]   = guru_nnExec(model.ac, dset.X, dset.X);
    imgs = reshape(o, [dset.nInput size(o,2)]);
    
    de_PlotOutputImages_2D( ...
        imgs,...
        dset, ...
        sprintf('Instance image plot, o=%4.1f', model.sigma) ...
      );
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_Average2D(models, dset)
  %2d plot
    fig = guru_newFig('images-avg', 'images', dset);
    
    imgs = zeros([dset.nInput size(dset.X,2)]);
    for i=1:length(models)
      model = de_LoadProps(models(i), 'ac', 'Weights');
      [o]   = guru_nnExec(model.ac, dset.X, dset.X);
      imgs = imgs + reshape(o, [dset.nInput size(o,2)])/length(models);
    end;
    
    de_PlotOutputImages_2D( ...
        imgs,...
        dset, ...
        sprintf('Average image plot, o=%4.1f', model.sigma) ...
      );
