function fig = de_visualizeData(dset, nImages)
  % View some sample images
  subplot_size = [3, 4]; % the size of the subplot dimensions.
  max2show = subplot_size(1) * subplot_size(2); 
  % Note that subplot_size should never be too small (it will limit the size
  % of the selected set of numbers), but it may be too big if it's not
  % chosen properly. 
  
  
  if ~exist('nImages', 'var')
    nImages = size(dset.X,2);
  end;
  
  nImages = min(nImages, max2show); %more than max2show and the code will break
  
  n_pix = prod(dset.nInput);
  img_shape = dset.nInput;
  im2show     = de_SelectImages(dset, nImages); %for vanhateren nImage = 16, but size(im2show) = 20?
  
  fig = de_NewFig('dataset-images', '__img', img_shape, length(im2show));
  set(fig.handle, 'Position', [0, 0, 1200, 1200]);

  for ii=1:length(im2show) %make sure only 16 are shown
      subplot(subplot_size(1), subplot_size(2), ii); %
      colormap gray;
      img = reshape(dset.X(1:n_pix, im2show(ii)), img_shape);
      img_min = min(img);
      img_max = max(img);
      if ~isscalar(img_min) %make sure that it is the global min/max
          img_min = min(img_min);
          img_max = min(img_max);
      end
      
      img = img - img_min; % smallest value is 0
      if (ii>min(nImages/2, length(im2show)/2))
          img = img / (img_max - img_min);
      end
      imagesc( img, [0, 1]);
      axis image; set(gca, 'xtick',[],'ytick',[]);
      lbl = dset.XLAB{im2show(ii)};
      if isfield(dset, 'TLAB')
          lbl = sprintf('%s\n%s', lbl, dset.TLAB{im2show(ii)});
          if (ii>min(nImages/2, length(im2show)/2))
              ylabel('Normalized power')
          end
      end;
      xlabel(guru_text2label(lbl));
  end;
