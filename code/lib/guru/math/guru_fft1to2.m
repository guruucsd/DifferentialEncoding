function [freqs1D,powers1D] = guru_fft1to2(freqs, fftsz)
%
% Takes a 2D fft, and converts it to a 1D FFT

  guru_assert(false);

    global fftsz_ x_ y_ rho_ freqs1D_

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

    global fftsz_ x_ y_ rho_ freqs1D_

    if (length(size(imgs))==2), imgs  = reshape(imgs, [1 size(imgs)]); end;
    if (~exist('fftsz','var')), fftsz = [size(imgs,2) size(imgs,3)]; end;

    % First time at this size, so must compute everything
    if (isempty(fftsz_) || any(fftsz_ - fftsz))
        [freqs1D_, rho_, x_, y_] = guru_freq2to1( fftsz_ );
    end;




  [~,freqs_1D]   = guru_fft2to1(fftshift(avgPowerOrig2D));
guru_assert(false);

  centerpt=ceil(size(img)/2);
  [y,x] = find(img==0|img~=0);
  [theta, rho] = cart2pol(x-centerpt(2),y-centerpt(1));

  freqs1D     = [];
  powersets1D = {};

  for i=1:length(theta)
    freqidx = find(freqs1D==rho(i));
    if (isempty(freqidx))
      freqidx = length(freqs1D)+1;
      freqs1D(freqidx) = rho(i);
      powersets1D{freqidx} = [];
    end;

    % Gotta translate back from theta/rho to
    curpower = img(y(i),x(i));

    powersets1D{freqidx} = [powersets1D{freqidx} curpower];
  end;


  % Average
  powers1D = zeros(size(powersets1D));
  for i=1:length(powersets1D)
    powers1D(i) = mean(powersets1D{i});
  end;

  % Sort
  [freqs1D,sidx] = sort(freqs1D);
  powers1D = powers1D(sidx);

  % Plot
  %plot(freqs,powers);
