%% Load dataset
image_set = 'navon';
image_opt = {'noise', 0.1, 'small'};
%image_opt = {'small'};

switch image_set
    case 'navon'
        load(de_MakeDataset('sergent_1982', 'de', 'sergent', image_opt));
        train.X = 1 - train.X;
        start_img = 4;
        show_img = 16;
        bgcolor = [0 0 0];
        axis_padding = [-0.25 1.25];

    case 'faces'
        load(de_MakeDataset('young_bion_1981', 'orig', '', image_opt));
        start_img = 4;
        bgcolor = [0 0 0];
        axis_padding = [-0.5 1.5];

    case 'gratings'
        load(de_MakeDataset('christman_etal_1991', 'low_freq', '', image_opt));
        start_img = 4;
        bgcolor = [0 0 0];
        axis_padding = [-0.25 1.25];

    case 'task'
        load(de_MakeDataset('kitterle_etal_1992', 'sf_mixed', '', image_opt));
        start_img = 1;
        bgcolor = [0 0 0];
        axis_padding = [-0.5 1.5];

    case 'conbal'
        %load(de_MakeDataset('jonsson_hellige_1986', 'sf_mixed', ''));
        %load(de_MakeDataset('lamb_yund_1993', 'sf_mixed', ''));

    case 'natimg'
        load(de_MakeDataset('vanhateren', '256', '', image_opt));
        start_img = 10;
        bgcolor = [1 1 1];
        axis_padding = [-0.5 1.5];

    otherwise
        error('Unknown image set: %s', image_set);
end;


%% Demo 1: single image
Z = show_img;
TheImage = reshape(double(train.X(:, Z)), train.nInput); 

figure; surf(Z*ones(size(TheImage)), TheImage, 'EdgeColor', 'none');
colormap('gray');
whitebg(gcf, [0 0 0]);

set(gca, 'ytick', [], 'xtick', [], 'ztick', [])
view(-49.5, -44);
%set(gcf, 'Position', [])


%% Demo 2: stack of images
nimages = size(train.X, 2);
figure('Position', [   440    36   560   748]);
for Z=start_img:floor(nimages/4):nimages
    TheImage = reshape(double(train.X(:, Z)), train.nInput); 
    TheImage = TheImage(end:-1:1, :);
    surf(Z * ones(size(TheImage)), TheImage, 'EdgeColor', 'none'); 
    alpha 0.9
    hold on;%if (Z == 1), hold on; end;
end;
colormap('gray');
whitebg(gcf, bgcolor);

set(gca, 'ytick', [], 'xtick', [], 'ztick', []);
set(gca, 'zlim', Z * axis_padding);
view(57.5, 10.5);

export_fig(gcf, sprintf('image_stack_%s.png', image_set), '-transparent');
