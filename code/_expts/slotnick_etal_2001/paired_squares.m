%% Takes three parameters: 2 are distances from quartile lines
%% Last parameter: if four_pixel = 1, then the square will be 4 pixels. For all other values it will be 1 pixel
%% If four_pixel = 1, valid range for distances is  [2, 4]. If four_pixel != 1, valid range is [2, 5]. Anything
%% outside this range will have weird output.

function image = paired_squares_stimuli(left_distance, right_distance, four_pixel)

image_height = 34;
image_width = 25;

horizontal_midline = image_height/2;
vertical_midline = ceil(image_width/2);

left_quarterline = floor(image_width/4);
right_quarterline = image_width - left_quarterline; 

image = ones(image_height, image_width);

for ii = 2:image_height-1
    image(ii, vertical_midline) = 0;
end


image(horizontal_midline, left_quarterline-left_distance+1) = 0;
image(horizontal_midline, left_quarterline+left_distance) = 0;
image(horizontal_midline, right_quarterline+right_distance) = 0;
image(horizontal_midline, right_quarterline-right_distance+1) = 0;

if (four_pixel == 1) 

image(horizontal_midline, left_quarterline-left_distance) = 0;
image(horizontal_midline+1, left_quarterline-left_distance) = 0;
image(horizontal_midline+1, left_quarterline-left_distance+1) = 0;

image(horizontal_midline+1, left_quarterline+left_distance) = 0;
image(horizontal_midline, left_quarterline+left_distance+1) = 0;
image(horizontal_midline+1, left_quarterline+left_distance+1) = 0;


image(horizontal_midline, right_quarterline-right_distance) = 0;
image(horizontal_midline+1, right_quarterline-right_distance) = 0;
image(horizontal_midline+1, right_quarterline-right_distance+1) = 0;

image(horizontal_midline+1, right_quarterline+right_distance) = 0;
image(horizontal_midline, right_quarterline+right_distance+1) = 0;
image(horizontal_midline+1, right_quarterline+right_distance+1) = 0;
end

end
