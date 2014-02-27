function [xyimgs] = de_pol2img(rtimgs, location, nInput)
%function [xyimgs] = de_pol2img(rtimgs, location, nInput)
%
% Take an image dataset, and a visual field location,
% and outputs a polar image (r,theta)

    % Defaults
    if ~exist('location','var'), location='CVF'; end;
    if ~exist('nInput','var'), nInput = size(rtimgs); nInput=nInput(1:end-1); end;

    % useful params
    nimg  = size(rtimgs, ndims(rtimgs));
    npix = prod(nInput);
    outsz = size(rtimgs);

    %
    rtimgs = reshape(rtimgs,[npix nimg]);
    xyimgs = zeros(npix,nimg);

    %
    for ii=1:nimg
        rtimg = reshape(rtimgs(:,ii), nInput);

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
        xyimgs(:,ii) = xyimg(:);
    end;

    xyimgs = reshape(xyimgs, outsz);