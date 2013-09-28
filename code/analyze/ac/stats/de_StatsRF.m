function [stats_fft] = de_StatsRF(mSets, mss)

    global selectedHUs_;
    if (isempty(selectedHUs_))
        nhu = 16;
        selectedHUs_ = round(linspace(1,mSets.nHidden,nhu+2));
        selectedHUs_ = selectedHUs_(2:end-1);
    end;
    nhu = length(selectedHUs_);
    
    for ii=1:length(mss)
        for mi=1:length(mss{ii})
            model = mss{ii}(mi);
            
            % Load weights
            
            % Get hu activation for each image
            norient=8;
            nfreq=floor(min(mSets.nInput));
            pwr = zeros(nhu, nfreq,norient);
            
            for oi=1:norient;
               theta = pi*(oi-1)/norient;
               for fi=1:nfreq
                   cycles = nfreq/(nfreq-fi-1);
                   
                   img = mfe_grating2d(1/cycles,0,theta,0.5,nInput(1),nInput(2));
                   
                   
                   % Forward pass
                   [~,~,o_p] = 
                   for hui=1:nhu
                       
                   end;
               end;
            end;
        end;
    end;
            
    
    if (~iscell(images)), images = {images}; end; % next two "massages" allow original image set
	switch length(size(images{1}))
		case 2          %     and reconstructed image sets to be processed by the same code
			for ii=1:length(images)
				images{ii} = reshape(images{ii}, [1 nInput, size(images{ii}, length(size(images{ii})))]);
			end;
		case 3
			for ii=1:length(images)
				images{ii} = reshape(images{ii}, [1 size(images{ii})]);
			end;
	end;

    nInput  = size(images{1});
    nInput  = nInput(2:end-1); %first dim=model instances; last dim=# images
    
    if (length(nInput)~=2)
        error('FFT stats can only be run for 2D simulations.');
    end;

    ffts      = cell(length(images),1);
    power1D   = cell(length(images),1 );
    phase1D   = cell(length(images),1 );

    padfactor = 2;
    sigmas    = [0.0 0.5 3.0];
 
    nImages = size(images{1},4);
    npad    = padfactor*nInput; %padding for fft
    fftSz   = nInput + npad;



    %%%%%%%%%%%%%%%%%%
    % Eeeverything, for original images
    %%%%%%%%%%%%%%%%%%

	freqs_1D = guru_freq2to1(fftSz);
  


    %%%%%%%%%%%%%%%%%%
    % Now, for each model
    %%%%%%%%%%%%%%%%%%

    for ii=1:length(images)
        fprintf('\n\t[model instances]: ');
        
    	nModels = size(images{ii},1);
    	
        % Declare variables
        ffts{ii}      = zeros([nModels nImages fftSz]);
        power1D{ii}   = zeros(length(sigmas), nModels, length(freqs_1D));
        phase1D{ii}   = zeros(nModels, length(freqs_1D));
    
		%%%%%%%%%%%%%%%%%%
		% 2D Processing
		%%%%%%%%%%%%%%%%%%
            
        for mi=1:size(images{ii}, 1)
            fprintf( '%d ', mi);
            
            imgs = reshape(images{ii}(mi,:,:,:), [nInput nImages]);

            % Process each image individually
            for jj=1:nImages
                img  = reshape(imgs(:,:,jj), nInput);
                cfft = fft2(img, size(img,1)+npad(1), size(img,2)+npad(2));
                ffts{ii}(mi,jj,:,:) = reshape(cfft, [1 1 fftSz]);
            end;
            clear('model','imgs');
        end;

        %%%%%%%%%%%%%%%%%%
        % 1D Processing
        %%%%%%%%%%%%%%%%%%
        
        pwr = reshape( mean(     ffts{ii} .*conj(ffts{ii}),2), [nModels fftSz] );
        phs = reshape( mean(real(ffts{ii})./imag(ffts{ii}),2), [nModels fftSz] );
    
        [phase1D{ii}] = guru_fft2to1( fftshift(phs), fftSz );
        [pwr1D]            = guru_fft2to1( fftshift(pwr), fftSz );
        
        fprintf('[1D freqs] ');
        for si=1:length(sigmas)
        
            if (sigmas(si)==0.0)
                power1D{ii}(si, :, :) = pwr1D;
        
            % Smooth the power
            else
                for fi=1:length(freqs_1D)
                    g = normpdf(freqs_1D, freqs_1D(fi), sigmas(si)); % find gaussian at all points, centered around current
                    g = g/sum(g); % normalize weights to sum to 1
                    power1D{ii}(si, :, fi)  = sum(pwr1D .* repmat(g, [nModels 1]), 2);
                end;
            end;
        end;
    end;
  


    %%%%%%%%%%%%%%%%%%
    % Repackaging
    %%%%%%%%%%%%%%%%%%
    
    stats_fft.padfactor     = padfactor;
    stats_fft.ffts = ffts;
    
    % Normalize freqs
    stats_fft.freqs_1D = freqs_1D/(padfactor+1);
    stats_fft.smoothing_sigmas = sigmas;
    stats_fft.fftsz    = fftSz;
    
    stats_fft.power1D = power1D;
    stats_fft.phase1D = phase1D;
    