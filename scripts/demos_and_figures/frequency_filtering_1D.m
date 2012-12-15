% Demo of 1D frequency filtering on 2D image

addpath(genpath('../../code'))

% Load a face & compute fft
cutoff_freq = 10;
img = mfe_getpgmraw('~/datasets/CAFE/raw/032_s2.pgm');
fq  = fft2(img);

[f1D,f1D_map] = guru_freq2to1(size(img));
% Define low spatial frequency indices
lsf_idx = fftshift(f1D_map <= cutoff_freq);
hsf_idx = fftshift(f1D_map > cutoff_freq);

% Filter image for lsf
fq_lsf = fq;
fq_lsf(hsf_idx)=0;
img_lsf = ifft2(fq_lsf);
img_lsf = sqrt(img_lsf.*conj(img_lsf));
img_lsf = img_lsf(1:size(img,1),1:size(img,2));

% Filter image for hsf
fq_hsf = fq;
fq_hsf(lsf_idx)=0;
img_hsf = ifft2(fq_hsf);
img_hsf = sqrt(img_hsf.*conj(img_hsf));
img_hsf = img_hsf(1:size(img,1),1:size(img,2));


figure;


% Show original image
subplot(2,3,1);
colormap('gray');
imagesc(img);
mfe_freezeColors;

% Show frequency spectrum power, as image (brightness component removed)
subplot(2,3,4);
colormap('jet');
fq(1,1)=0;
imagesc(fftshift(fq.*conj(fq)));
mfe_freezeColors;


% Show low-frequency components of image
subplot(2,3,2);
colormap('gray');
imagesc(img_lsf);
mfe_freezeColors;

% Show frequency spectrum power, as image (brightness component removed)
subplot(2,3,5);
colormap('jet');
fq_lsf(1,1)=0;
imagesc(fftshift(fq_lsf.*conj(fq_lsf)));
mfe_freezeColors;


% Show high-frequency components of image
subplot(2,3,3);
colormap('gray');
imagesc(img_hsf);
mfe_freezeColors;

subplot(2,3,6);
colormap('jet');
fq_hsf(1,1)=0;
imagesc(fftshift(fq_hsf.*conj(fq_hsf)));
mfe_freezeColors;

mfe_unfreezeColors;
