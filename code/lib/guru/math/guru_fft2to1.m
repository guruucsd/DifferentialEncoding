function [powers1D,freqs1D_sorted_] = guru_fft2to1(imgs, fftsz)
%
% Takes a 2D fft, and converts it to a 1D FFT

    global fftsz_ x_ y_ theta_ rho_ freqs1D_ freqs1D_sorted_ sortidx_
  
    if (length(size(imgs))==2), imgs  = reshape(imgs, [1 size(imgs)]); end;
    if (~exist('fftsz','var')), fftsz = [size(imgs,2) size(imgs,3)]; end;
  
    % First time at this size, so must compute everything
    if (isempty(fftsz_) || any(fftsz_ - fftsz))

        fftsz_ = fftsz;
        centerpt=ceil(fftsz_/2);
        [y_,x_] = find(squeeze(imgs(1,:,:))==0|squeeze(imgs(1,:,:))~=0);
        [theta_, rho_] = cart2pol(x_-centerpt(2),y_-centerpt(1));

        freqs1D_     = [];
        for i=1:length(theta_)
            freqidx = find(freqs1D_==rho_(i));
            if (isempty(freqidx))
                freqidx = length(freqs1D_)+1;
                freqs1D_(freqidx) = rho_(i);
            end;
        end;
        [freqs1D_sorted_,sortidx_] = sort(freqs1D_); %need unsorted freqs, as they match up with rho
    end;
  
    % Compute the 1D power
    powersets1D = repmat({zeros(size(imgs,1), 0)}, size(freqs1D_));

    for ti=1:length(theta_)
        freqidx = find(freqs1D_==rho_(ti));

        % Gotta translate back from theta/rho to 
        curpower = imgs(:,y_(ti),x_(ti));

        powersets1D{freqidx}(:,end+1) = curpower;
    end;
    

    % Average 
    powers1D = zeros(size(imgs,1),length(powersets1D));
    for fi=1:length(powersets1D)
        powers1D(:,fi) = mean(powersets1D{sortidx_(fi)},2); %average while sorting
    end;
