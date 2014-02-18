function [freqs1D, rho, x, y  ] = guru_pixeldist(sz2D)
%
% Takes a 2D fft, and converts it to a 1D FFT

    centerpt=(sz2D-1)/2;

    [x,y] = meshgrid(1:sz2D(2), 1:sz2D(1));
    %x = reshape(x, prod(size(x)), 1);
    %y = reshape(y, prod(size(y)), 1);

    [~, rho] = cart2pol(x-centerpt(2)-1,y-centerpt(1)-1);
    freqs1D = unique(rho(:))';
