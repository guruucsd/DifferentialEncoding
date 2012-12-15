function [stats_fft] = de_StatsFFTs(mss,dset)
%
  if (length(mss{1}(1).nInput)~=2)
    error('FFT stats can only be run for 2D simulations.');
  end;
  
  ffts = cell(size(mss));
  
  for i=1:length(mss)
    models = mss{i};
    
    nImages = size(dset.X,2);
    imgSz = models(1).nInput;
    ffts{i} = zeros([length(models) nImages imgSz]);
    
    for j=1:length(models)
      model = de_LoadProps(models(j), 'ac', 'Weights');
      [imgs]   = guru_nnExec(model.ac, dset.X, dset.X);

      fprintf( '%d ', j);
      
      for k=1:nImages
        img = reshape(imgs(:,k), imgSz);
        %img = img - mean(mean(img));
        cfft = fft2(img);
        ffts{i}(j,k,:,:) = reshape((cfft.*conj(cfft)), [1 1 imgSz]);
      end;
    end;
    fprintf('\t');
  end;
  
  fprintf('\t original images');
  origffts = zeros([nImages imgSz]);
  for k=1:nImages
    img = reshape(dset.X(:,k), imgSz);
    %img = img - mean(mean(img));
    cfft = fft2(img);
    origffts(k,:,:) = reshape((cfft.*conj(cfft)), [1 model.nInput]);
  end;
  
  stats_fft.model = ffts;
  stats_fft.orig  = origffts;