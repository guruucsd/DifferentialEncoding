function [img, orig_img, c_orig_img]  = scrub_image(img_file, rotang, color_channel, thresh)
    if ~exist('rotang','var'),        rotang = 0; end;
    if ~exist('color_channel','var'), color_channel='bw'; end;
    if ~exist('thresh', 'var'),       thresh = 170; end;
    
    % Read image
    c_orig_img = imread(img_file);
    bw_orig_img = rgb2gray(c_orig_img);
    switch color_channel
        case 'r', orig_img = reshape(c_orig_img(:,:,1), [size(c_orig_img,1) size(c_orig_img,2)]);
        case 'g', orig_img = reshape(c_orig_img(:,:,2), [size(c_orig_img,1) size(c_orig_img,2)]);
        case 'b', orig_img = reshape(c_orig_img(:,:,3), [size(c_orig_img,1) size(c_orig_img,2)]);
        case 'bw',     orig_img = bw_orig_img;
    end;
    img = orig_img;
    
    % binarize and invert the image
    img(img>=thresh) = 255; img(img<thresh) = 0;
    img(img>0)=1; img=~img;


    % rotate image. do this after inverting, so that added pixels don't
    % interfere.
    if rotang ~= 0, img = imrotate(img, rotang); end;
