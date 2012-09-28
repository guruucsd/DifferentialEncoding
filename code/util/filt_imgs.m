
%%%%%%%%%%%%%%%%
function fimgs = filt_imgs( imgs, sz, G )

    fimgs = zeros(size(imgs));
    for jj=1:size(imgs,2)
        fc = reshape(imgs(:,jj), sz);
        fc = imfilter(fc,G,'same');
        fimgs(:,jj) = reshape(fc, [prod(sz) 1]);
    end;