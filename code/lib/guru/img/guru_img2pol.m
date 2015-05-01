function [rtimgs] = guru_img2pol(xyimgs, location, nInput)
% Take an image dataset, and a visual field location,
% and outputs a polar image (r,theta)
%

    % Defaults
    if ~exist('location','var'), location='CVF'; end;
    if ~exist('nInput','var'), nInput = size(xyimgs); nInput=nInput(1:end-1); end;

    % useful params
    nimg  = size(xyimgs, ndims(xyimgs));
    npix = prod(nInput);
    outsz = size(xyimgs);

    %
    xyimgs = reshape(xyimgs,[npix nimg]);
    rtimgs = zeros(npix,nimg);

    %
    for ii=1:nimg
        switch location

            case 'CVF'
                xyimg = reshape(xyimgs(:,ii), nInput);
                rtimg = mfe_img2pol(xyimg);

            case 'CVF-RH' % polar: 90 to 270 degrees
                xyimg = reshape(xyimgs(:,ii), nInput);
                rtimg = mfe_img2pol(xyimg);

                deg90_idx = size(rtimg,2) / 4;
                deg270_idx = 3 * size(rtimg, 2) / 4;

                % ceil & floor allow LH & RH to be stitched together
                rtimg(:, [ceil(deg270_idx):end 1:ceil(deg90_idx - 1)]) = 0;
                rtimg = rtimg(:, [ceil(deg90_idx):end 1:ceil(deg90_idx-1)]);

            case 'CVF-LH' % polar: 270 to 0, 0 to 90 degrees
                xyimg = reshape(xyimgs(:,ii), nInput);
                rtimg = mfe_img2pol(xyimg);

                deg90_idx = size(rtimg,2) / 4;
                deg270_idx = 3 * size(rtimg, 2) / 4;

                % ceil & floor allow LH & RH to be stitched together
                rtimg(:, [ceil(deg90_idx):ceil(deg270_idx - 1)]) = 0;
                rtimg = rtimg(:, [ceil(deg90_idx):end 1:ceil(deg90_idx-1)]);

            case {'LVF','RVF'}

                % Right-pad images
                xyimg = zeros(nInput(1), nInput(2)*2);
                xyimg(:,1:nInput(2)) = reshape(xyimgs(:,ii), nInput);

                rtimg = mfe_img2pol(xyimg);

                % Strip off padding
                npad = nInput(2)/2;
                rtimg = rtimg(:,1+floor(npad):end-ceil(npad));

                % Flip image if RVF instead of LVF
                if (strcmp(location,'RVF'))
                    rtimg = rtimg(:, end:-1:1); % flip image across vertical afor RVF
                end;
        end;
        rtimgs(:,ii) = rtimg(:);
    end;

    rtimgs = reshape(rtimgs, outsz);