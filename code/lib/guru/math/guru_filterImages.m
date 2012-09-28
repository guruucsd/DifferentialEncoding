function [filt_images, filt] = guru_filterImages(images, filterType, filterParams)
%
%
  if (length(size(images))==2), images=reshape(images,[1 size(images)]); end;
  

  filt_images = zeros(size(images));
  num_images  = size(images,1);
  size_images = [size(images,2) size(images,3)];
  
  switch (filterType)
      case 'lowpass'
        [~,rho] = guru_freq2to1(size_images);
        for ii=1:num_images
          img                 = reshape(images(ii,:,:), size_images);
          img_fft2            = fft2(img);
          filt_fft2           = img_fft2.*ifftshift(rho<=filterParams(1));
          filt_image          = ifft2(filt_fft2);
          filt_image          = real(filt_image);%sqrt(filt_image .* conj(filt_image)); % remove any imaginary part
          filt_images(ii,:,:) = filt_image;

          guru_assert(all(isreal(filt_image(:))));
        end;
        
      case 'highpass'
        [~,rho] = guru_freq2to1(size_images);
        for ii=1:num_images
          img                 = reshape(images(ii,:,:), size_images);
          img_fft2            = fft2(img);
          filt_fft2           = img_fft2.*ifftshift(rho>=filterParams(1));
          filt_image          = ifft2(filt_fft2);
          filt_image          = real(filt_image);%filt_image .* conj(filt_image);
          filt_images(ii,:,:) = filt_image;

          guru_assert(all(isreal(filt_image(:))));
        end;

      case 'bandpass'
        semi_filt_images = guru_filterImages(images, 'lowpass', filterParams(2));
        filt_images      = guru_filterImages(semi_filt_images, 'highpass', filterParams(1));

  end;
      
  
  
  