function [selectedImages, nImages] = de_SelectImages(dset, nImages)
%
%
  if (~exist('nImages', 'var')), nImages = 20; end;

  global selectedImages_;

  if (isempty(selectedImages_) ...                 % not yet selected
      || (max(selectedImages_)>size(dset.X,2)) ... % selected on a larger dataset
      || (max(selectedImages_)<size(dset.X,2)/2)) % selected on a much smaller dataset
      [un_lbls,imgIdx] = unique(dset.XLAB);
      selectedImages_   = randperm(length(un_lbls)); %so that we get to see a variety
      selectedImages_   = selectedImages_( unique(round(linspace(1, length(un_lbls), nImages))) );
      selectedImages_   = sort(imgIdx(selectedImages_))' % so that they're grouped by stimulus type
  end;

  selectedImages = selectedImages_;
  nImages = length(selectedImages);
