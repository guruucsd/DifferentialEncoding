function [xyimgs] = guru_pol2img(rtimgs, location)
%function [xyimgs] = guru_pol2img(rtimgs, location)
%
% Take a polarimage, or image dataset, and a visual field location,
% and outputs a cartesian image
%
% rtimgs: 3D array of polar images ([height width nImgs]) or 2D image ([
% height width])
% location: CVF, CVF-RH, CVF-LH, LVF, RVF

    % Defaults
    if ~exist('location','var'), location='CVF'; end;

    sz = size(rtimgs);
    nInput = sz(1:2);
    

    % Deal with an entire image set.
    if ndims(rtimgs) > 2
        nimg = prod(sz(3:end));
        rtimgs = reshape(rtimgs, [nInput, nimg]);
        xyimgs = zeros(size(rtimgs));
        for ii=1:nimg
            xyimgs(:, :, ii) = guru_img2pol(rtimgs(:, :, ii), location); 
        end;
        return
    end;

    % useful params
    npix = prod(nInput);
    rtimg = rtimgs;  % alias

    switch location
        case 'CVF'
            xyimg = mfe_pol2img(rtimg);

        case {'LVF','RVF'}
            if (strcmp(location,'RVF'))                % Flip image if RVF instead of LVF
                rtimg = fliplr(rtimg);
            end;

            % center-pad images
            rtpadimg = zeros(nInput(1), nInput(2)*2);
            npad = nInput(2)/2;
            rtpadimg(:,1+floor(npad):end-ceil(npad)) = rtimg;

            xypadimg = mfe_pol2img(rtpadimg);

            % Image is at the left side
            xyimg = xypadimg(:,1:nInput(2));

            % Strip off padding
    end;

    xyimg(isnan(xyimg)) = 0; %
    xyimgs = xyimg