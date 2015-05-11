function [freqs1D, rho, x, y] = guru_freq2to1(sz2D, padfactor)
%function [freqs1D, rho, x, y] = guru_freq2to1(sz2D, padfactor)
%
% Takes a 2D size, and returns all 1D frequencies
%
% Input:
%   sz2D: [height width] of image
%   padfactor: # of times image size is replicated to pad with zeros
%              (which increases resolution)
%
% Output:
%   freqs1D: all unique 1D frequencies
%   rho:     1D frequency at each pixel in the image
%
% Example:
% [freqs1D] = guru_freq2to1(size(img));
    if ~exist('padfactor', 'var'), padfactor = 0; end;
    guru_assert(padfactor >= 0);

    centerpt=(sz2D-1)/2; % center of image

    [x,y] = meshgrid(1:sz2D(2), 1:sz2D(1)); %x and y across image
    %x = reshape(x, prod(size(x)), 1);
    %y = reshape(y, prod(size(y)), 1);

    [~, rho] = cart2pol(x-centerpt(2)-1,y-centerpt(1)-1);
    freqs1D = unique(rho(:))';
    freqs1D = freqs1D / (padfactor + 1);
