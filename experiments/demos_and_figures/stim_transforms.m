%% This script was used for COGSCI 2014, to generate figures
%% showing log-polar and blurring image transforms applied there.

addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
de_SetupExptPaths('sergent_1982');

%% Figure 1
[~, set_orig] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {}, false);
[~, set_img2pol] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'img2pol', 'location', 'LVF'}, false);
[~, set_blurred] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'img2pol', 'location', 'LVF', 'lowpass', 10}, false);

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
xlabel('Low-pass (cutoff = 10cpd)');




%% Figure 2
hemi_labels = {'RH', 'LH'};
kernels = { ...
    [3  5  6.5  11  16  NaN] ...
    [6.5 11 16 NaN NaN NaN], ...
};
nhemis = length(kernels);
figure; set(gcf, 'Position', [121         340        1319         444]);
for hi=1:2
    k = kernels{hi};
    nkernels = length(k);
    for ki=1:nkernels
        [~, dset] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'lowpass', k(ki), 'small'}, false);%'blurring', k(ki), 'small'}, false);

        subplot(nhemis, nkernels, nkernels * (hi - 1) + ki); set(gca, 'FontSize', 14);
        imshow(reshape(dset.X(:, 12), dset.nInput));
        if isnan(k(ki)), tit = 'full fidelity';
        else, tit=sprintf('cutoff = %2.1fcpd', k(ki));
        end;

        if ki < nkernels,   tit = sprintf('Iteration %d:\n%s', ki, tit);
        else, tit = sprintf('Full fidelity\n(train to criterion)');
        end;

        if hi == 1, title(tit);
        else,         xlabel(tit);
        end;
        if ki == 1, ylabel(hemi_labels{hi}, 'FontSize', 18); end;
    end;
end;

%export_fig(gcf, 'fig9.png', '-transparent'); close(gcf);
%export_fig(gcf, 'fig2.png', '-transparent'); close(gcf);
