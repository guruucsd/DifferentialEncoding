function [rtimgs] = de_img2pol(xyimgs, location, nInput)
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