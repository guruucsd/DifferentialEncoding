function [fig] = de_PlotOutputImages(models, dset)
%function [fig] = de_PlotOutputImages(models,dset)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
% dset          : dataset of original (input) images
%
% Output:
% h             : array of handles to plots

  global selectedImages;
  if (isempty(selectedImages) || (max(selectedImages)>size(dset.X,2))) %so that all reproductions use the same set
      selectedImages  = randperm(size(dset.X,2)); %so that we get to see a variety
      selectedImages  = selectedImages( unique(round(linspace(1, size(dset.X,2), 20))) );
      selectedImages  = sort(selectedImages) % so that they're grouped by stimulus type
  end;
  
  % Hack for an error that I don't feel like correcting in current sims
  if (~isfield(dset, 'nInput') && isfield(dset,'X') && size(dset.X,1)==403)
      dset.nInput = [31 13];
  end;
  
  
  fig        = de_NewFig('dummy');
  
  % Hacky way to allow plotting of the original input images
  if (isempty(models))
      fig(end+1) = de_PlotOutputImages_Original(dset);
  else
      fig(end+1) = de_PlotOutputImages_Instance2D(models(1), dset);
      fig(end+1) = de_PlotOutputImages_Average2D(models, dset);
  end;
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_Original( dset )
    global selectedImages;
    
    fig = de_NewFig('images-orig', 'images', dset);
    
    de_PlotOutputImages_2D( ...
        reshape(dset.X(:,selectedImages), [dset.nInput length(selectedImages)]),...
        dset, ...
        'original' ...
      );  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotOutputImages_2D( o, obj, t, cx)
  %2d plot
  
    global selectedImages;
  
    if (~exist('cx','var'))
        cx      = [min(min(obj.X)) max(max(obj.X))];
    end;
    
    [nRows,nCols]   = guru_optSubplots(size(o,3));
    
    for ii=1:size(o,3)
      i = selectedImages(ii);
      img = squeeze(o(:,:,ii));
      
      % Plot the connectivity pattern
      subplot(nRows, nCols, ii);
      colormap(gray);
      imagesc(img, cx);
      hold on;

      set(gca, 'xtick',[],'ytick',[]);
      if (isfield(obj, 'TLAB'))
          lab = sprintf('%s: (%s)', obj.XLAB{i}, obj.TLAB{i});
      else
          lab = obj.XLAB{i};
      end;
      
      xlabel(lab);
    end;
    
    %
    hold on;
    mfe_suptitle(t);
      
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_Instance2D(model, dset)
  %2d plot
  
    global  selectedImages;
    
    fig = de_NewFig('images-inst', 'images', dset);
    
    model = de_LoadProps(model, 'ac', 'Weights');
  
    [o]   = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(:,selectedImages));
    imgs  = reshape(o, [dset.nInput size(o,2)]);
    
    cx    = model.ac.minmax;
    
    de_PlotOutputImages_2D( ...
        imgs,...
        dset, ...
        sprintf('Instance image plot, o=%4.1f', model.sigma), ...
        cx ...
      );
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotOutputImages_Average2D(models, dset)
  %2d plot
  
    global  selectedImages;

    fig = de_NewFig('images-avg', 'images', dset);
    
    imgs = zeros([dset.nInput length(selectedImages)]);
    for i=1:length(models)
      model = de_LoadProps(models(i), 'ac', 'Weights');
      [o]   = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(:,selectedImages));
      imgs = imgs + reshape(o, [dset.nInput size(o,2)])/length(models);
    end;
    
    cx    = models(1).ac.minmax;

    de_PlotOutputImages_2D( ...
        imgs,...
        dset, ...
        sprintf('Average image plot, o=%4.1f', model.sigma), ...
        cx ...
      );
