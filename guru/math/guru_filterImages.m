function [filt_images] = guru_filterImages(images, filterType, filterParams, showfig)
%function [filt_images] = guru_filterImages(images, filterType, filterParams)
%
% Spatial frequency filtering of images
%
%Input:
% images: 2D image, or 3D array of images ([nimg height width])
% filterType: lowpass, highpass, bandpass
% filterParams: maxfreq, minfreq, [minFreq maxFreq]
% showfig : show sample unfiltered & filtered image
%
%Output:
% filt_images : filtered images
%
  if ~exist('showfig','var'), showfig = false; end;
  if (length(size(images))==2), images=reshape(images,[1 size(images)]); end;
  

  filt_images = zeros(size(images));
  num_images  = size(images,1);
  size_images = [size(images,2) size(images,3)];
  
  
  switch (filterType)
      case 'lowpass',  [filt_images] = guru_filterImages(images, 'bandpass', [0 filterParams]);
      case 'highpass', [filt_images] = guru_filterImages(images, 'bandpass', [filterParams inf]);
      case 'bandpass'
        [~,rho] = guru_freq2to1(size_images);
        for ii=1:num_images
          img                 = reshape(images(ii,:,:), size_images);
          img_fft2            = fft2(img);
          filt_fft2           = img_fft2.*ifftshift(filterParams(1)<=rho & rho<=filterParams(2));
          filt_image          = ifft2(filt_fft2);
          filt_image          = real(filt_image);%sqrt(filt_image .* conj(filt_image)); % remove any imaginary part
          filt_images(ii,:,:) = filt_image;

          guru_assert(all(isreal(filt_image(:))));
        end;
  
          %
        if showfig
          figure('Position',[25 -21 1106 705]); 
          subplot(1,2,1); imshow(img); subplot(1,2,2); imshow(filt_image/255);
        end;        
  end;
  
  
  