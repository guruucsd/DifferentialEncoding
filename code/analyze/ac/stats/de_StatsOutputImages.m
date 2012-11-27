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
      m = models(mi);

      if ~isfield(m.ac,'output')
        try
           error('Can''t cache this property without taking into account the dataset, whcih we currently don''t do!');
           m = de_LoadProps(m,ac,'output');
        catch
          if (~isfield(m.ac, 'Weights'))
              m = de_LoadProps(m, 'ac', 'Weights');
          end;
          [m.ac.output]   = guru_nnExec(m.ac, dset.X(:,selectedImages), dset.X(1:end-1,selectedImages));
        end;
      end;
      images{si}(mi,:,:,:)  = reshape(m.ac.output, [dset.nInput nImages]);

      if guru_hasopt(dset.opt, 'img2pol')
        for ii=1:nImages
            rtimg = squeeze(images{si}(mi,:,:,ii));
            xyimg = guru_pol2img(rtimg);
            images{si}(mi,:,:,ii) = xyimg;
        end;
      end;
    end;
  end;

