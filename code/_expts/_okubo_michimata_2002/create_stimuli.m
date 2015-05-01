%% Takes two parameters: height (vertical displacement of 2 dots from middle 5), above (1 for true, 0 for false, i.e. below)

function [ image ] = create_cat_coord_stimuli( height, above )
img_height = 50;
img_width = 68;
midline = img_height/2;
stimuli_mid = img_width/2;
five_stimuli_width = 44;
padding = 12;

image = ones(img_height, img_width);

% create the five stimuli, same on all images
for ii = 1:10:41
  image(midline, padding+ii) = 0;
  image(midline+1, padding+ii) = 0;
  image(midline, padding+ii+1) = 0;
  image(midline+1, padding+ii+1) = 0;
end

if above == 1 
    height = height * -1;
end
% create the 2 stimuli based on the height

image(midline+height,29) = 0;
image(midline+height, 28) = 0;
image(midline+height+1, 29) = 0;
image(midline+height+1, 28) = 0;

image(midline+height, 39) = 0;
image(midline+height, 38) = 0;
image(midline+height+1, 39) = 0;
image(midline+height+1, 38) = 0;
end

