addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

% I want each pixel's correlation with all other pixels, for all pixles.
% Then I want to average that correlation over all pixels of the image.
% THEN I want to average over all distances.
%
if true || ~exist('corr_map', 'var')
    %load(de_MakeDataset('vanhateren', '256', '', {'small'}));
    %load(de_MakeDataset('sergent_1982', 'de', '', {'small'}));
    %load(de_MakeDataset('young_bion_1981', 'orig', '', {'small'}));
    %load(de_MakeDataset('kitterle_etal_1992', 'sf_mixed', '', {'small'}));
    load(de_MakeDataset('text', 'kangaroos', '', {'medium', 'fontsize', '16', 'fontname', 'arial', 'skip', 1000}));
    
    npix = size(train.X, 1);
    nimages = size(train.X, 2);
    corr_map = corr(train.X');
    corr_map(isnan(corr_map(:))) = 0;
end;

corr_img = cell(npix, 1);
corr_avg_img = zeros(train.nInput * 2);
midpt = train.nInput + 1;
for pi=1:npix
    corr_img{pi} = reshape(corr_map(pi,:), train.nInput);
    
    % Now reposition
    [y, x] = ind2sub(train.nInput, pi);
    mupos = [y x];

    corr_img_recentered = zeros(size(corr_avg_img));
    
    corr_img_recentered([midpt(1):end]-mupos(1), [midpt(2):end]-mupos(2)) ...
        = corr_img{pi};

      corr_avg_img = corr_avg_img + corr_img_recentered / npix;
end;

figure('name', 'example correlation map'); imshow(corr_img{1});
figure('name', 'correlation average'); imshow(corr_avg_img);
figure('name', '100 * correlation average'); imshow(100 * corr_avg_img);
