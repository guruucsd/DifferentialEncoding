addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
fullfile(fileparts(which(mfilename)), '..', '..', 'code')
de_SetupExptPaths('sergent_1982');

%% Figure 1 
[~, set_orig] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {}, false);
[~, set_img2pol] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'img2pol', 'location', 'LVF'}, false);
[~, set_blurred] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'img2pol', 'location', 'LVF', 'blurring', 8}, false);

% Now place images side-by-side, with labels.
figure; set(gcf, 'Position', [317   276   795   502]);

subplot(1,3,1); set(gca, 'FontSize', 14); 
imshow(reshape(set_orig.X(:, 1), set_orig.nInput));
xlabel('Navon figure');

subplot(1,3,2); set(gca, 'FontSize', 14); 
imshow(reshape(set_img2pol.X(:, 1), set_orig.nInput));
xlabel('Log-polar (LVF)');

subplot(1,3,3); set(gca, 'FontSize', 14); 
imshow(reshape(set_blurred.X(:, 1), set_orig.nInput));
xlabel('Gaussian blurring (\sigma = 8px)');




%% Figure 2
kernels = [8 6 4 2 1 0];
kernels = [3 5 6.5 11 16 NaN];
nkernels = length(kernels);
figure; set(gcf, 'Position', [121         439        1071         345]);
for ki=1:nkernels
    [~, dset] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'lowpass', kernels(ki), 'small'}, false);%'blurring', kernels(ki), 'small'}, false);
    subplot(1, nkernels, ki); set(gca, 'FontSize', 14); 
    imshow(reshape(dset.X(:, 12), dset.nInput));
    xlabel(sprintf('\\sigma = %2.1fpx', kernels(ki)));
end;
