function [images] = de_StatsOutputImages(mss, dset, selectedImages)
%function [fig] = de_StatsOutputImages(models, dset)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
% dset          : dataset of original (input) images
%
% Output:
% h             : array of handles to plots

  if (~exist('selectedImages','var') || isempty(selectedImages))
      selectedImages = de_SelectImages(dset);
  end;
  nImages = length(selectedImages); % # images we got

  images = cell(size(mss));
  for mi=1:length(mss)
    models = mss{mi};
    if isempty(models), continue; end;

    images{mi} = zeros([length(models), models(1).nInput, nImages]);

    for ii=1:length(models)
      if (isfield(models(ii).ac, 'Weights'))
          model = models(ii);
      else
          model = de_LoadProps(models(ii), 'ac', 'Weights');
      end;

      [o]   = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(1:end-1,selectedImages));
      images{mi}(ii,:,:,:)  = reshape(o, [dset.nInput nImages]);
    end;
  end;
