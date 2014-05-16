function [freqs1D, rho, x, y] = guru_freq2to1(sz2D)
%function [freqs1D, rho, x, y] = guru_freq2to1(sz2D)
%
% Takes a 2D size, and returns all 1D frequencies
%
% Input:
%   sz2D: [height width] of image
%
% Output:
%   freqs1D: all unique 1D frequencies
%   rho:     1D frequency at each pixel in the image
%
% Example:
% [freqs1D] = guru_freq2to1(size(img));

    centerpt=(sz2D-1)/2; % center of image

    [x,y] = meshgrid(1:sz2D(2), 1:sz2D(1)); %x and y across image
    %x = reshape(x, prod(size(x)), 1);
    %y = reshape(y, prod(size(y)), 1);

    [~, rho] = cart2pol(x-centerpt(2)-1,y-centerpt(1)-1);
    freqs1D = unique(rho(:))';
