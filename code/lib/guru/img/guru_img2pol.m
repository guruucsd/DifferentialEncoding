function rtimg = guru_img2pol(xyimg)
%
%

    % Cache results of computation
    global rtcoeff_ rtsz_
    if isempty(rtsz_) || any(rtsz_ - size(xyimg))
        rtsz_ = size(xyimg);
        rtcoeff_ = guru_img2pol_mat(rtsz_);
    end;

    rtimg = reshape(rtcoeff_ * xyimg(:), rtsz_);
    