function [powers1D,freqs1D_] = guru_fft2to1(imgs, fftsz)
%function [powers1D,freqs1D_] = guru_fft2to1(imgs, fftsz)
%
% Takes a 2D fft, and converts it to a 1D FFT
%
% 

    % Some globals, for efficient caching
    global fftsz_ x_ y_ rho_ freqs1D_;
  
    if (length(size(imgs))==2), imgs  = reshape(imgs, [1 size(imgs)]); end;
    if (~exist('fftsz','var')), fftsz = [size(imgs,2) size(imgs,3)]; end;
  
    % First time at this size, so must compute everything
    if (isempty(fftsz_) || any(fftsz_ - fftsz))
        fftsz_ = fftsz;
        [freqs1D_, rho_, x_, y_] = guru_freq2to1( fftsz_ );
    end;
  
  
    % Compute the 1D power
    powersets1D = repmat({zeros(size(imgs,1), 0)}, size(freqs1D_));

    for fi=1:length(freqs1D_)
        freqidx = find(rho_==freqs1D_(fi));

        powersets1D{fi} = zeros([size(imgs,1) size(freqidx)]);%(:,end+1) = curpower;
        for ti=1:length(freqidx)
            powersets1D{fi}(:,ti) = imgs(:,y_(freqidx(ti)),x_(freqidx(ti)));  % Gotta translate back from theta/rho to x,y
        end;
    end;
    

    % Average 
    powers1D = zeros(size(imgs,1),length(powersets1D));
    for fi=1:length(powersets1D)
        powers1D(:,fi) = mean(powersets1D{fi},2); %average sorted list
    end;
