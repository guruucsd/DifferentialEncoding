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
  for si=1:length(mss)
    models = mss{si};
    if isempty(models), continue; end;

    images{si} = zeros([length(models), models(1).nInput, nImages]);

    for mi=1:length(models)
      if (isfield(models(mi).ac, 'Weights'))
          model = models(mi);
      else
          model = de_LoadProps(models(mi), 'ac', 'Weights');
      end;

      [o]   = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(1:end-1,selectedImages));

      % Convert back from polar to regular image
%      if guru_hasopt(dset.opt, 'img2pol')
%          o = de_pol2img(o, guru_getopt(dset.opt,'location','CVF'),dset.nInput);
%      end;
      
      images{si}(mi,:,:,:)  = reshape(o, [dset.nInput nImages]);
    end;
  end;
  
