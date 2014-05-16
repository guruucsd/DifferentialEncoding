function [img_hat, errors] = gfReconstructFast(filtered, filters, nEpoch)
% Reconstruct the original image given the gabor manitudes and gabor
% filters
%
% filtered: a cell of size nFrequencies*nOrientations, containing the
%           magnitudes of the gabor responses of the original image which
%           we want to reconstruct.
% filters:  a cell of size nFrequencies*nOrientations, containing the gabor
%           filters we applied on the original image
% nEpoch:   the number of iterations we want the reconstruction algorithm
%           to iterate.
% img_hat:  the reconstructed image based on the gabor magnitudes
%           "filtered" and the gabor filters "filters"
% errors:   this array shows how the error reduces with each iteration of
%           the algorithm

% get the number of filters
[nFrequencies, nOrientations] = size(filters);

% get the size of the image and filters
[height, width] = size(filtered{1,1});
gf_size = zeros(nFrequencies, 2);
for f = 1:nFrequencies
    gf_size(f,:) = size(filters{f,1});
end;

% calculate the size of the filter on the frequency domain and the border
d = zeros(nFrequencies, 1);
border = zeros(nFrequencies, 2);
for f = 1:nFrequencies
    d(f) = 2^ceil(log2(max(height,width)+max(gf_size(f,:))-1));
    border(f,:) = floor(0.5*gf_size(f,:))+1;
end;

% pad filters with zeros, and fft2 to frequency domain
filters_padded = cell(nFrequencies, nOrientations);
for f = 1:nFrequencies
    for j = 1:nOrientations
        filter_padded = zeros(d(f));
        filter_padded(1:gf_size(f,1), 1:gf_size(f,2)) = filters{f,j};
        filters_padded{f,j} = fft2(filter_padded);
    end;
end;

% get the support enforcement mask
support_mask = cell(nFrequencies, nOrientations);
gg_frequency = [3*pi/256 3*pi/128 3*pi/64 3*pi/32 3*pi/16 3*pi/8 3*pi/4];
for f = 1:nFrequencies
    for j = 1:nOrientations
        gf_orientation = j*pi/nOrientations;
        filter = gfCreateFilter(gg_frequency(f), gf_orientation, [height width]);
        filter = filter(1:height, 1:width);
        reponse = reshape(abs(fft2(filter)), 1, height*width);
        support_mask{f,j} = find(reponse<0.0001);
    end;
end;

% randomly choose an initial image
img_hat = randn(height, width);
errors = zeros(1, nEpoch);

% reconstruct the image by gradient descent
filtered_hat = cell(nFrequencies, nOrientations);
for epoch = 1:nEpoch
    fprintf(1, 'processing epoch %d ...\n', epoch);

    % combine the phase of the estimated image with the magnitude of the
    % original image, and do DFT on this "faked" image
    % then support enforcement
    % then IGWT, then real
    for f = 1:nFrequencies
        img_padded = zeros(d(f));
        img_padded(1:height, 1:width) = img_hat;
        img_padded = fft2(img_padded);
        for j = 1:nOrientations
            response = angle(ifft2(filters_padded{f,j} .* img_padded));
            response = response(border(f,1):height+border(f,1)-1, border(f,2):width+border(f,2)-1);
            response = fft2(filtered{f,j} .* exp(i*response));
            response = reshape(response, 1, height*width);
            response(support_mask{f,j}) = 0;
            response = reshape(response, [height width]);
            response = real(ifft2(response));
            filtered_hat{f,j} = response;
        end;
    end;

    % IDFT, IGWT, then keep the real part
    img_hat = zeros(height, width);
    for f = 1:nFrequencies
        for j = 1:nOrientations
            img_hat = img_hat + filtered_hat{f,j};
        end;
    end;
end;
img_hat = reshape(prestd(reshape(img_hat,1,height*width)), [height width]);