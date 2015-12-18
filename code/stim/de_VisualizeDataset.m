function fig = de_visualizeData(dset, nImages)
  % View some sample images

  if ~exist('nImages', 'var')
    nImages = min(4*4, size(dset.X,2));
  end;

  n_pix = prod(dset.nInput);
  img_shape = dset.nInput;
  im2show     = de_SelectImages(dset, nImages);

  fig = de_NewFig('dataset-images', '__img', img_shape, nImages);
  set(fig.handle, 'Position', [0, 0, 1200, 1200]);

  for ii=1:length(im2show)
      subplot(4, 4, ii);
      colormap gray;
      imagesc( reshape(dset.X(1:n_pix, im2show(ii)), img_shape), [0, 1]);
      axis image; set(gca, 'xtick',[],'ytick',[]);
      lbl = dset.XLAB{im2show(ii)};
      if isfield(dset, 'TLAB')
          lbl = sprintf('%s\n%s', lbl, dset.TLAB{im2show(ii)});
      end;
      xlabel(guru_text2label(lbl));
  end;
