function [stats_fft] = de_StatsFFTs(dset, images)
%
% Compute 1D and 2D FFT phase, FFT power, and (for each) average error from original.

    nInput = dset.nInput;
    guru_assert(length(nInput)==2, 'FFT stats can only be run for 2D simulations.');

    % next two "massages" allow original image set
    if (~iscell(images)), images = {images}; end;

    switch ndims(images{1})
        case 2          %     and reconstructed image sets to be processed by the same code
            for ii=1:length(images)
                images{ii} = reshape(images{ii}, [1 nInput, size(images{ii}, length(size(images{ii})))]);
            end;
        case 3
            for ii=1:length(images)
                images{ii} = reshape(images{ii}, [1 size(images{ii})]);
            end;
    end;


    % Convert any polar images back to rectangular.
    if guru_hasopt(dset.opt, 'img2pol')
        for si=1:length(images)
            for mi=1:size(images{si},1)
                images{si}(mi,:,:,:) = guru_pol2img(squeeze(images{si}(mi,:,:,:)), guru_getopt(dset.opt,'location','CVF'),dset.nInput);
            end;
            guru_assert(~any(isnan(images{si}(:))));
            guru_assert(all(isreal(images{si}(:))));
            guru_assert(isempty(dset.minmax) || (dset.minmax(1) <= all(images{si}(:))));
            guru_assert(isempty(dset.minmax) || (dset.minmax(2) >= all(images{si}(:))));
        end;
    end;

    % Continue processing
    ffts      = cell(length(images),1);
    power1D   = cell(length(images),1 );
    phase1D   = cell(length(images),1 );

    % These could be settings to be passed in, but whatever.
    padfactor = 2;  % fft padding, to remove effects of aliasing.
    sm_sigmas = [0.0 0.5 3.0];  % how we're going to smooth.  Note: can be 1D and 2D

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
        power1D{ii}   = zeros(length(sm_sigmas), nModels, length(freqs_1D));
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

        mean_pwr = reshape( mean(     ffts{ii} .*conj(ffts{ii}),2), [nModels fftSz] );
        mean_phs = reshape( mean(real(ffts{ii})./imag(ffts{ii}),2), [nModels fftSz] );
        std_pwr  = reshape( std(      ffts{ii} .*conj(ffts{ii}),[], 2), [nModels fftSz] );
        std_phs  = reshape( std( real(ffts{ii})./imag(ffts{ii}),[], 2), [nModels fftSz] );

        [mean_pwr1D]       = guru_fft2to1( fftshift(mean_pwr), fftSz );
        [mean_phase1D{ii}] = guru_fft2to1( fftshift(mean_phs), fftSz );
        [std_pwr1D]        = guru_fft2to1( fftshift(std_pwr), fftSz );
        [std_phase1D{ii}]  = guru_fft2to1( fftshift(std_phs), fftSz );

        fprintf('[1D freqs] ');
        for si=1:length(sm_sigmas)

            if (sm_sigmas(si)==0.0)
                mean_power1D{ii}(si, :, :) = mean_pwr1D;
                std_power1D{ii}(si, :, :)  = std_pwr1D;

            % Smooth the power
            else
                for fi=1:length(freqs_1D)
                    g = normpdf(freqs_1D, freqs_1D(fi), sm_sigmas(si)); % find gaussian at all points, centered around current
                    g = g/sum(g); % normalize weights to sum to 1
                    mean_power1D{ii}(si, :, fi)  = sum(mean_pwr1D .* repmat(g, [nModels 1]), 2);
                    std_power1D{ii}(si, :, fi)   = sum(std_pwr1D  .* repmat(g, [nModels 1]), 2);
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
    stats_fft.smoothing_sigmas = sm_sigmas;
    stats_fft.fftsz    = fftSz;

    stats_fft.power1D.mean = mean_power1D;
    stats_fft.power1D.std  = std_power1D;
    stats_fft.phase1D.mean = mean_phase1D;
    stats_fft.phase1D.std  = std_phase1D;
