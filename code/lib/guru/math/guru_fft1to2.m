function [freqs1D,powers1D] = guru_fft1to2(freqs, sz2D)
%
% Takes a 2D fft, and converts it to a 1D FFT
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
