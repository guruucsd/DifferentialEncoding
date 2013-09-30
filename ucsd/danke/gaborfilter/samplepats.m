function [L, R] = samplepats(filelist, patfolder, hsample, vsample)
% S = samplepats(filelist, patfolder, hsample, vsample)
%
% SAMPLPATS reads patterns from the filelist, and re-sample them with a
% hsample-by-vsample grid, centered at the image center; for equal sampling
% at both visual fields, even hsample is recommended. Equal-sized images are
% assumed.
% 
% L,R returns a 4D matrix with indices hsample, vsample, gabor_num, img_num.
% for the left and right hemisphere respectively

% check params
if mod(hsample,2)~=0
    disp('Sample size (hsample) must be even for the horizontal axis.');
    return;
end

% init
mask = [];
img = 0;

% read file list
fid=fopen(filelist);
while (1)
    % read line
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    % get the file name (should be the first thing of the line
    [strFile tline]=strtok(tline);
    [strFile tline]=strtok(strFile,'.');
    strFile = [strFile '.pat'];

    disp(['Reading pat file ' strFile ' ..']);
    [pat frequency orientation imgheight imgwidth] = readpat([patfolder strFile], 2);
    
    % Create sampling mask
    if isempty(mask)
        hstep = floor( (imgwidth - 1) / hsample );
        vstep = floor( (imgheight - 1) / vsample );
        hstart = 1 + floor((imgwidth - hstep * (hsample-1) - 1) / 2);
        vstart = 1 + floor((imgheight - vstep * (vsample-1) - 1) / 2);
        mask = zeros(imgheight, imgwidth);
        vpoints = vstart:vstep:imgheight;
        hpoints = hstart:hstep:imgwidth;   
        mask(vpoints, hpoints) = 1; % fill the mask
        lvf_points = hpoints(1:length(hpoints)/2);
        rvf_points = hpoints(length(hpoints)/2+1 : end);
    end
    
    % Perform sampling, s is 3D, location x scale x orient
    img = img + 1;
    s = pat(vpoints, hpoints, :, :);
    rh_input = pat(hpoints, lvf_points, :, frequency / 2 + 1 : end);    % left vis. field and low freq
    lh_input = pat(hpoints, rvf_points, :, 1 : frequency / 2);          % right vis. field and hi freq
    
    L(img, :) = lh_input(:)';
    R(img, :) = rh_input(:)';
end
