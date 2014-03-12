function filtered = gfFilterImages(images, filters, height, width)
% filtered = gfFilterImages(images, filters, height, width)
% apply filters on images
%
%       imgs: images to be filtered; each column is an image
%       filters: gabor filters, should be a matrix of cells
%       height, width: define the size of an image
%       filtered: gabor magnitudes

% get the number of filters and images
[nFrequencies, nOrientations] = size(filters);
[D, N] = size(images);

% get the size of the filters
gf_size = zeros(nFrequencies, 2);
for i = 1:nFrequencies
    gf_size(i,:) = size(filters{i,1});
end;

% calculate the size of the filter on the frequency domain and the border
d = zeros(nFrequencies, 1);
border = zeros(nFrequencies, 2);
for i = 1:nFrequencies
    d(i) = 2^ceil(log2(max(height,width)+max(gf_size(i,:))-1));
    border(i,:) = floor(0.5*gf_size(i,:))+1;
end;

% pad filters with zeros, and fft2 to frequency domain
filters_padded = cell(nFrequencies, nOrientations);
for i = 1:nFrequencies
    for j = 1:nOrientations
        filter_padded = zeros(d(i));
        filter_padded(1:gf_size(i,1), 1:gf_size(i,2)) = filters{i,j};
        filters_padded{i,j} = fft2(filter_padded);
    end;
end;

% get the filtered images
filtered = zeros(N, D*nFrequencies*nOrientations);
for m = 1:N
    for i = 1:nFrequencies
        img_padded = zeros(d(i));
        img_padded(1:height, 1:width) = reshape(images(:,m), [width height])';
        img_padded = fft2(img_padded);
        base = (i-1)*nOrientations*D;
        for j = 1:nOrientations
            response = abs(ifft2(filters_padded{i,j} .* img_padded));
            response = response(border(i,1):height+border(i,1)-1, border(i,2):width+border(i,2)-1);
            filtered(m, base+(j-1)*D+1:base+(j-1)*D+D) = reshape(response, 1, D);
        end;
    end;
end;