function [rtimgs] = guru_img2pol(xyimgs, location)
% Take an image, or image dataset, and a visual field location,
% and outputs a polar image (r,theta)
%
% xyimgs: 3D array of images ([height width nImgs]) or 2D image ([
% height width])
% location: CVF, CVF-RH, CVF-LH, LVF, RVF


    % Defaults
    if ~exist('location','var'), location='CVF'; end;

    sz = size(xyimgs);
    nInput = sz(1:2);
    
    % Deal with an entire image set.
    if ndims(xyimgs) > 2
        nimg = prod(sz(3:end));
        xyimgs = reshape(xyimgs, [nInput, nimg]);
        rtimgs = zeros(size(xyimgs));
        for ii=1:nimg
            rtimgs(:, :, ii) = guru_img2pol(xyimgs(:, :, ii), location); 
        end;
        return
    end;

    % useful params
    npix = prod(nInput);
    xyimg = xyimgs;  % alias

    switch location
        case 'CVF'
            rtimg = mfe_img2pol(xyimg);

        case 'CVF-RH' % polar: 90 to 270 degrees
            rtimg = mfe_img2pol(xyimg);

            deg90_idx = size(rtimg,2) / 4;
            deg270_idx = 3 * size(rtimg, 2) / 4;

            % ceil & floor allow LH & RH to be stitched together
            rtimg(:, [ceil(deg270_idx):end 1:ceil(deg90_idx - 1)]) = 0;
            rtimg = rtimg(:, [ceil(deg90_idx):end 1:ceil(deg90_idx-1)]);

        case 'CVF-LH' % polar: 270 to 0, 0 to 90 degrees
            rtimg = mfe_img2pol(xyimg);

            deg90_idx = size(rtimg,2) / 4;
            deg270_idx = 3 * size(rtimg, 2) / 4;

            % ceil & floor allow LH & RH to be stitched together
            rtimg(:, [ceil(deg90_idx):ceil(deg270_idx - 1)]) = 0;
            rtimg = rtimg(:, [ceil(deg90_idx):end 1:ceil(deg90_idx-1)]);

        case {'LVF','RVF'}

            % Right-pad images
            xyimg2 = zeros(nInput(1), nInput(2)*2);
            xyimg2(:,1:nInput(2)) = reshape(xyimg, nInput);

            rtimg = mfe_img2pol(xyimg2);

            % Strip off padding
            npad = nInput(2)/2;
            rtimg = rtimg(:,1+floor(npad):end-ceil(npad));

            % Flip image if RVF instead of LVF
            if (strcmp(location,'RVF'))
                rtimg = rtimg(:, end:-1:1); % flip image across vertical afor RVF
            end;
    end;

    rtimgs = rtimg;