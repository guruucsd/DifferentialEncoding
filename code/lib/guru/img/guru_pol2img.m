function xyimg = guru_pol2img(rtimg)
%
%

    % Cache results of computation
    global xycoeff_ xysz_ rtcoeff_ rtsz_
    if isempty(xysz_) || any(xysz_ - size(rtimg))
        if isempty(rtsz_) || any(rtsz_ - size(rtimg))
            rtcoeff_ = guru_img2pol_mat(simg(rtimg));
            rtsz_ = size(rtimg);
        end;

        xysz_ = rtsz_;
        %xycoeff_ = pinvs(rtcoeff_);
    end;
    
    xyimg = reshape(rtcoeff_ \ rtimg(:), xysz_);
    