function [fig] = de_PlotOutputImages(models,  imgs, lbls)
%function [fig] = de_PlotOutputImages(models, imgs, lbls)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
% imgs          : dataset of original (input) images; ultimately will be
%                 [ (# models) (width) (height) (# images)]
% lbls

% Output:
% h             : array of handles to plots

  fig        = de_NewFig('dummy');

  % Missing # models and # images
  if (length(size(imgs))==2)
      imgs = reshape(imgs, [1 models.nInput size(imgs,2)]);
  elseif (length(size(imgs))==3)
      imgs = reshape(imgs, [1 size(imgs)]);
  end;

  if (~exist('lbls','var')), lbls = cell(size(imgs,4),1); end;


  % Hacky way to allow plotting of the original input images
  sz = size(imgs);
  if (length(models(1).sigma) ~= 1), sigma='orig'; else sigma=sprintf('%3.2f', models(1).sigma); end;

  fig(end+1) = de_PlotOutputImages_2D( ['images-inst-' sigma], ...
                                       reshape(imgs(1,:,:,:), sz(2:4)), ...
                                       lbls, [0 1]);
  fig(end+1) = de_PlotOutputImages_2D( ['images-mean-' sigma], ...
                                       reshape(mean(imgs,1),  sz(2:4)), ...
                                       lbls, [0 1]);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_2D( fig_lbl, imgs, lbls, cx)
  %2d plot

    if (~exist('cx','var'))
        cx      = [min(imgs(:)) max(imgs(:))];
    end;

    fig        = de_NewFig(fig_lbl);
    [nRows,nCols]   = guru_optSubplots(size(imgs,3));

    for ii=1:size(imgs,3)
      img = squeeze(imgs(:,:,ii));
      img = img - min(img(:));
      % Plot the connectivity pattern
      subplot(nRows, nCols, ii);
      colormap(gray);
      imagesc(img, cx);
      hold on;

      set(gca, 'xtick',[],'ytick',[]);
      if (~isempty(lbls{ii})), xlabel(guru_text2label(lbls{ii})); end;
    end;

    %
    hold on;
    mfe_suptitle(fig_lbl);

