function [stats_fft] = de_StatsFFTs(mss,dset)
%
  if (length(mss{1}(1).nInput)~=2)
    error('FFT stats can only be run for 2D simulations.');
  end;
  
  ffts = cell(size(mss)); %size will be: {#settings}[#models #testimages #freqs]
  
  for i=1:length(mss)
    models = mss{i};
    
    nImages = size(dset.X,2);
    imgSz = models(1).nInput;
    ffts{i} = zeros([length(models) nImages imgSz]);
    
    for j=1:length(models)
      fprintf( '%d ', j);
      
      % Calc output
      model = de_LoadProps(models(j), 'ac', 'Weights'); %loads the NN
      [imgs]   = guru_nnExec(model.ac, dset.X, dset.X); %gets the output of the NN

      % Calc ffts
      for k=1:nImages
        img = reshape(imgs(:,k), imgSz);
        %img = img - mean(mean(img));
        
        ffts{i}(j,k,:,:) = fft2(img);
        %cfft = fft2(img);
        %ffts{i}(j,k,:,:) = reshape((cfft.*conj(cfft)), [1 1 imgSz]);
      end;
    end;
    fprintf('\t');
  end;
  %keyboard;
  
  fprintf('\t original images');
  origffts = zeros([nImages imgSz]);
  for k=1:nImages
    img = reshape(dset.X(:,k), imgSz);
    %img = img - mean(mean(img));

    origffts(k,:,:) = fft2(img);
    %cfft = fft2(img);
    %origffts(k,:,:) = reshape((cfft.*conj(cfft)), [1 model.nInput]);
  end;
  
  stats_fft.model = ffts;
  stats_fft.orig  = origffts;
  
  %keyboard
