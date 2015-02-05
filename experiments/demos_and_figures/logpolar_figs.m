vanilla = load(de_MakeDataset('vanhateren', '250', ''));
img2pol = load(de_MakeDataset('vanhateren', '250', '', {'img2pol'}));
img2pol_lvf = load(de_MakeDataset('vanhateren', '250', '', {'img2pol', 'location', 'LVF'}));

for ii=84:94
figure('position', [68   386   802   398]);
subplot(1,3,1); imshow(reshape(vanilla.train.X(:,ii ), train.nInput)); xlabel('Original', 'FontSize', 16);
subplot(1,3,2); imshow(reshape(img2pol.train.X(:,ii), train.nInput)); xlabel('logpolar', 'FontSize', 16);
subplot(1,3,3); imshow(reshape(img2pol_lvf.train.X(:,ii), train.nInput)); xlabel('logpolar @ LVF', 'FontSize', 16);
end;
export_fig(gcf, 'natural_images.png', '-transparent')


%% sergent
vanilla = load(de_MakeDataset('sergent_1982', 'sergent', ''));
img2pol = load(de_MakeDataset('sergent_1982', 'sergent', '', {'img2pol'}));
img2pol_lvf = load(de_MakeDataset('sergent_1982', 'sergent', '', {'img2pol', 'location', 'LVF'}));

figure('position', [68   386   802   398]);
subplot(1,3,1); imshow(reshape(vanilla.train.X(:,2), train.nInput)); xlabel('Original', 'FontSize', 16);
subplot(1,3,2); imshow(reshape(img2pol.train.X(:,2), train.nInput)); xlabel('logpolar', 'FontSize', 16);
subplot(1,3,3); imshow(reshape(img2pol_lvf.train.X(:,2), train.nInput)); xlabel('logpolar @ LVF', 'FontSize', 16);
export_fig(gcf, 'navon_figures.png', '-transparent')

%% faces
vanilla = load(de_MakeDataset('young_bion_1981', 'orig', ''));
img2pol = load(de_MakeDataset('young_bion_1981', 'orig', '', {'img2pol'}));
img2pol_lvf = load(de_MakeDataset('young_bion_1981', 'orig', '', {'img2pol', 'location', 'LVF'}));

figure('position', [68   386   802   398]);
subplot(1,3,1); imshow(reshape(vanilla.train.X(:,2), train.nInput)); xlabel('Original', 'FontSize', 16);
subplot(1,3,2); imshow(reshape(img2pol.train.X(:,2), train.nInput)); xlabel('logpolar', 'FontSize', 16);
subplot(1,3,3); imshow(reshape(img2pol_lvf.train.X(:,2), train.nInput)); xlabel('logpolar @ LVF', 'FontSize', 16);
export_fig(gcf, 'navon_figures.png', '-transparent')
