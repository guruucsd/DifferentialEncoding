function [stats_fft] = de_StatsFFTs(mss,dset)
%
    if (length(mss{1}(1).nInput)~=2)
        error('FFT stats can only be run for 2D simulations.');
    end;
  
    padfactor = 2;
    sigmas    = [0.0 0.5 1.0 3.0];
 
 
    npad    = padfactor*mss{1}(1).nInput; %padding for fft
    nImages = size(dset.X,2);
    fftSz   = mss{1}(1).nInput + npad;

    % Declare variables
    ffts      = cell(1+length(mss),1);
    power1D   = cell( 3,1 );
    phase1D   = cell( 3,1 );
  

    %%%%%%%%%%%%%%%%%%
    % Eeeverything, for original images
    %%%%%%%%%%%%%%%%%%

    fprintf('\n\t[original images]');
    ffts{1} = zeros([nImages fftSz]);
    for ii=1:nImages
        img  = reshape(dset.X(1:end-1,ii), mss{1}(1).nInput);
        cfft = fft2(img, size(img,1)+npad(1), size(img,2)+npad(2));
        ffts{1}(ii,:,:) = reshape(cfft, [1 fftSz]);
    end;
    
    % Orig at index #1
    [power1D{1}, freqs_1D] = guru_fft2to1(fftshift( reshape(mean(    (ffts{1}).*conj(ffts{1}),1), fftSz) )); %average power over images
    [phase1D{1}]           = guru_fft2to1(fftshift( reshape(mean(real(ffts{1})./imag(ffts{1}),1), fftSz) )); %average phase over images


    %%%%%%%%%%%%%%%%%%
    % Now, for each model
    %%%%%%%%%%%%%%%%%%

    for i=1:length(mss)
        fprintf('\n\t[model instances]: ');
        models  = mss{i};
        nModels = length(models);
        
        % Declare variables
        ffts{1+i}      = zeros([nModels nImages fftSz]);
        power1D{1+i}   = zeros(length(sigmas), nModels, length(freqs_1D));
        phase1D{1+i}   = zeros(nModels, length(freqs_1D));
    
        for mi=1:length(models)
            fprintf( '%d ', mi);
            
            %%%%%%%%%%%%%%%%%%
            % 2D Processing
            %%%%%%%%%%%%%%%%%%
            
            % Get the 2D images
            model = de_LoadProps(models(mi), 'ac', 'Weights');
            [imgs]   = guru_nnExec(model.ac, dset.X, dset.X(1:end-1,:));

            % Process each image individually
            for ii=1:nImages
                img  = reshape(imgs(:,ii), models(mi).nInput);
                cfft = fft2(img, size(img,1)+npad(1), size(img,2)+npad(2));
                ffts{1+i}(mi,ii,:,:) = reshape(cfft, [1 1 fftSz]);
            end;
            clear('model','imgs');
        end;

        %%%%%%%%%%%%%%%%%%
        % 1D Processing
        %%%%%%%%%%%%%%%%%%
        
        pwr = squeeze( mean(     ffts{1+i}(:,:,:,:) .*conj(ffts{1+i}(:,:,:,:)),2) );
        phs = squeeze( mean(real(ffts{1+i}(:,:,:,:))./imag(ffts{1+i}(:,:,:,:)),2) );
    
        [phase1D{1+i}(:,:)] = guru_fft2to1( fftshift(phs), fftSz );
        [pwr1D]              = guru_fft2to1( fftshift(pwr), fftSz );
        
        fprintf('[1D freqs] ');
        % Smooth the power
        for si=1:length(sigmas)
            if (sigmas(si)==0.0)
                power1D{1+i}(si, :, :) = pwr1D;
            else
                for fi=1:length(freqs_1D)
                    g = normpdf(freqs_1D, freqs_1D(fi), sigmas(si)); % find gaussian at all points, centered around current
                    g = g/sum(g); % normalize weights to sum to 1
                    power1D{1+i}(si, :, fi)  = sum(pwr1D .* repmat(g, [nModels 1]), 2);
                end;
            end;
        end;
    end;
  

    %%%%%%%%%%%%%%%%%%
    % Stats tests
    %%%%%%%%%%%%%%%%%%

    % Now that we've smoothed each model instance's
    %   power spectrum according to the current Gaussian kernel,
    %   we need to do a statistical test at each frequency.
    %
    nSig    = length(sigmas);
    nFreq   = length( mss );
    nModels = min( size(power1D{2},2), size(power1D{end},2) ); %match sample sizes
    
    %ht  = zeros(nFreq,1); htl = zeros(nFreq,1);
    %pt  = zeros(nFreq,1); ptl = zeros(nFreq,1);
    %ha  = []; hal = []; %zeros(size(f,3),1);
    pals  = zeros(nSig,nFreq,1); sals = cell(nSig,nFreq,1);
    
    % Calc stats separately for each frequency
    for si=1:nSig
        for fi=1:nFreq
            %[htls(i), ptls(i)]   =ttest (    power1D{2}(si,1:nModels,i) - power1D{end}(si,1:nModels,i));
    
            [pals(si,fi)] =anova1(   [reshape(power1D{2}  (si,1:nModels,fi), [nModels 1]), ...
                                      reshape(power1D{end}(si,1:nModels,fi), [nModels 1])], ...
                                      {'rh','lh'}, 'off');
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%
    % Save off results
    %%%%%%%%%%%%%%%%%%

    stats_fft.model2D = ffts(2:end);
    stats_fft.orig2D  = ffts{1};
    
    % Normalize freqs
    stats_fft.freqs_1D = freqs_1D/(padfactor+1);
    stats_fft.smoothing_sigmas = sigmas;
    stats_fft.fftsz    = fftSz;
    
    stats_fft.model1D.power = power1D(2:end);
    stats_fft.orig1D.power = power1D{1};
    
    stats_fft.model1D.phase = phase1D(2:end);
    stats_fft.orig1D.phase = phase1D{1};
    
    stats_fft.model1D.pals  = pals;
    
    
    
