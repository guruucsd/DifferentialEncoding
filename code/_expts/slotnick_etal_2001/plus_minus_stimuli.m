%% distance = distance of CENTER of plus, minus from midpoint
%% distance = 0 means that the plus and minus are overlaid on top of each other
%% plus_on_right = 1 if you want the plus on the right, 0 if on the left


function image = plus_minus_stimuli(distance, plus_on_right)

image_height = 34;
image_width = 25;

image = ones(34, 25);

horiz_midline = (image_height)/2;
center = ceil(image_width/2);

for i = -1:1
    image(horiz_midline, center+distance+i) = 0;
    image(horiz_midline, center-distance-i) = 0;

if (plus_on_right == 1)
    image(horiz_midline+1, center+distance) = 0;
    image(horiz_midline-1, center+distance) = 0;
else
    image(horiz_midline+1, center-distance) = 0;
    image(horiz_midline-1, center-distance) = 0;
end

end
