function xyimg = guru_pol2img(rtimg)
%
%

    % Cache results of computation
    global xycoeff_ xysz_ rtcoeff_ rtsz_
    if isempty(xysz_) || any(xysz_ - size(rtimg))
        if isempty(rtsz_) || any(rtsz_ - size(rtimg))
            rtsz_ = size(rtimg);
            rtcoeff_ = guru_img2pol_mat(rtsz_);
        end;

        xysz_ = rtsz_;
        xycoeff_ = pinv(rtcoeff_);
    end;
    
    xyimg = reshape(xycoeff_ * rtimg(:), xysz_);
    