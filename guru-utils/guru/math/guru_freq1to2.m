function [img] = guru_freq1to2(freqs, sz2D)
%
% Takes a 2D fft, and converts it to a 1D FFT

  [x,y] = meshgrid(1:sz2D(2), 1:sz2D(1));

  centerpt=ceil(sz2D/2);

  [theta, rho] = cart2pol(x-centerpt(2),y-centerpt(1));

  img = ismember(rho, freqs);
