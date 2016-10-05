function [selectedImages, nImages] = de_SelectImages(dset, nImages)
%
%
  if (~exist('nImages', 'var')), nImages = 20; end;

  global selectedImages_;
  global selectedImages_max_;

  if (isempty(selectedImages_) ...                 % not yet selected
      || selectedImages_max_ ~= size(dset.X, 2))   % selected on a different dataset
      [un_lbls,imgIdx] = unique(dset.XLAB);
      selectedImages_   = randperm(length(un_lbls)); %so that we get to see a variety
      selectedImages_   = selectedImages_( unique(round(linspace(1, length(un_lbls), nImages))) );
      selectedImages_   = sort(imgIdx(selectedImages_))'; % so that they're grouped by stimulus type
      selectedImages_max_ = size(dset.X, 2);
  end;

  selectedImages = selectedImages_(1:min(nImages, length(selectedImages_))); %Actually use the nImages param...
  nImages = length(selectedImages);
