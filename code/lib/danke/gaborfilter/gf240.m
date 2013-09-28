% process images with gabor filters, image width 100, 6 scales, 8 orientations
% files are in the list: ..\CAFE\240list
% aligned images in folder: ..\CAFE\aligned\, output pat files in ..\CAFE\240pat\
gfFilterFolder('..\CAFE\240list', '..\CAFE\aligned', '..\CAFE\240pat', 100, 0, 6, 8, 1); 

% collate and sample gabor responses into L and R hemisphere inputs
[L, R] = samplepats('..\CAFE\240list', '..\CAFE\240pat', 12, 16); % each image is a row vector

% Normalize L R inputs over the training set, so each gabor magnitude
% contributes to the classification system equally
[nImg nGab] = size(L);

L = (L - ones(nImg, 1) * mean(L)) ./ (ones(nImg, 1) * std(L));
R = (R - ones(nImg, 1) * mean(L)) ./ (ones(nImg, 1) * std(L));

save LRraw.mat L R

% find principle components

load LRraw.mat

[vL,evL] = pca(L, 50);
[vR,evR] = pca(R, 50);

% PCA transform, each image is a row vecto

PCA_L = L * vL;
PCA_R = R * vR;

% z-score the PCA output
PCA_L = (PCA_L - ones(nImg, 1) * mean(PCA_L)) ./ (ones(nImg, 1) * std(PCA_L));
PCA_R = (PCA_R - ones(nImg, 1) * mean(PCA_R)) ./ (ones(nImg, 1) * std(PCA_R));

save PCA_output.mat PCA_L PCA_R

% Generate PDP++ input
load PCA_output.mat
genpdp('pdp.txt', '..\CAFE\240list', PCA_L, PCA_R);

