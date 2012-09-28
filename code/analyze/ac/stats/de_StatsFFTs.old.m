function [stats_fft] = de_StatsFFTs(mss, images)
%


    % Declare variables
    ffts      = cell(1+length(mss),1);
    power1D   = cell( 3,1 );
    phase1D   = cell( 3,1 );



    [a,b,c] = de_StatsFFTs_Big(mss, images, freqs_1D)

    %%%%%%%%%%%%%%%%%%
    % Save off results
    %%%%%%%%%%%%%%%%%%

    stats_fft.padfactor     = padfactor;

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
    
    if exist('pals','var')
      stats_fft.model1D.pals  = pals;
    end;  
    
    