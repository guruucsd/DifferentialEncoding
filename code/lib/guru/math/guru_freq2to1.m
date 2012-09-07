function [freqs1D] = guru_freq2to1(sz2D)
%
% Takes a 2D fft, and converts it to a 1D FFT

  [x,y] = meshgrid(1:sz2D(2), 1:sz2D(1));
  x = reshape(x, prod(size(x)), 1);
  y = reshape(y, prod(size(y)), 1);
  
  centerpt=ceil(sz2D/2);
  
  [theta, rho] = cart2pol(x-centerpt(2),y-centerpt(1));

  freqs1D     = [];

  for i=1:length(theta)
    freqidx = find(freqs1D==rho(i));
    if (isempty(freqidx))
      freqidx = length(freqs1D)+1;
      freqs1D(freqidx) = rho(i);
    end;
  end;

  % Sort
  [freqs1D,sidx] = sort(freqs1D);
