function filtered = gfFilterImage(img, filters, type)
% filtered = gfFilterImage(img, filters, type)
% apply filters on one single image
%
%   img: image to be filtered
%   filters: gabor filters, should be a matrix of cells
%   type: 1-abs(default); 2-real part; 3-imaginary part; 4-complex
%   filtered: gabor magnitudes

% set default type
if (nargin == 2)
    type = 1;
end;

% get the number of filters
[nFrequencies, nOrientations] = size(filters);

% get the size of the image and filters
[height, width] = size(img);
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
filtered = cell(nFrequencies, nOrientations);
for i = 1:nFrequencies
    img_padded = zeros(d(i));
    img_padded(1:height, 1:width) = img;
    img_padded = fft2(img_padded);
    for j = 1:nOrientations
        if (type == 1)
            response = abs(ifft2(filters_padded{i,j} .* img_padded));
        elseif (type == 2)
            response = real(ifft2(filters_padded{i,j} .* img_padded));
        elseif (type == 3)
            response = imag(ifft2(filters_padded{i,j} .* img_padded));
        elseif (type == 4)
            response = ifft2(filters_padded{i,j} .* img_padded);
        end;
        filtered{i,j} = response(border(i,1):height+border(i,1)-1, ...
                                border(i,2):width+border(i,2)-1);
    end;
end;