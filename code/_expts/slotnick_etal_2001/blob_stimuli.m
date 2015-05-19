function image = blob_stimuli(distance, dot_size)

center_of_blob = [34, 15]; %hardcoded
image_height = 68;
image_width = 50;


image = ones(image_height, image_width);

center_y = center_of_blob(1);
center_x = center_of_blob(2);


image(center_y, center_x+6) = 0;
image(center_y, center_x-6) = 0;
image(center_y+10, center_x) = 0;
image(center_y-10, center_x) = 0;
image(center_y-11, center_x) = 0;
image(center_y-12, center_x-1) = 0;
image(center_y-13, center_x-2) = 0;
image(center_y-13, center_x-3) = 0;
image(center_y-12, center_x-4) = 0;
image(center_y-11, center_x-5) = 0;
image(center_y-10, center_x-5) = 0;
image(center_y-9, center_x-5) = 0;
image(center_y-8, center_x-5) = 0;
image(center_y-7, center_x-4) = 0;
image(center_y-6, center_x-4) = 0;
image(center_y-5, center_x-4) = 0;
image(center_y-4, center_x-5) = 0;
image(center_y-3, center_x-5) = 0;
image(center_y-3, center_x-6) = 0;
image(center_y-2, center_x-6) = 0;
image(center_y-1, center_x-6) = 0;
image(center_y+1, center_x-6) = 0;
image(center_y+2, center_x-7) = 0;
image(center_y+3, center_x-7) = 0;
image(center_y+4, center_x-7) = 0;
image(center_y+5, center_x-8) = 0;
image(center_y+6, center_x-8) = 0;
image(center_y+7, center_x-8) = 0;
image(center_y+8, center_x-7) = 0;
image(center_y+9, center_x-6) = 0;
image(center_y+10, center_x-5) = 0;
image(center_y+9, center_x-4) = 0;
image(center_y+8, center_x-4) =0;
image(center_y+8, center_x-3) = 0;
image(center_y+7, center_x-3) = 0;
image(center_y+6, center_x-2) = 0;
image(center_y+7, center_x-1) = 0;
image(center_y+8, center_x-1) = 0;
image(center_y+9, center_x) = 0;
image(center_y+10, center_x+1) = 0;
image(center_y+11, center_x+1) = 0;
image(center_y+12, center_x+1) = 0;
image(center_y+13, center_x+2) = 0;
image(center_y+13, center_x+2) = 0;
image(center_y+13, center_x+2) = 0;
image(center_y+14, center_x+2) = 0;
image(center_y+14, center_x+3) = 0;
image(center_y+15, center_x+3) = 0;
image(center_y+15, center_x+3) = 0;
image(center_y+14, center_x+4) = 0;
image(center_y+13, center_x+5) = 0;
image(center_y+12, center_x+5) = 0;
image(center_y+11, center_x+5) = 0;
image(center_y+10, center_x+5) = 0;
image(center_y+9, center_x+4) = 0;
image(center_y+8, center_x+4) = 0;
image(center_y+7, center_x+5) = 0;
image(center_y+6, center_x+5) = 0;
image(center_y+5, center_x+5) = 0;
image(center_y+4, center_x+5) = 0;
image(center_y+3, center_x+6) = 0;
image(center_y+2, center_x+6) = 0;
image(center_y+2, center_x+5) = 0;
image(center_y+1, center_x+5) = 0;
image(center_y-1, center_x+6) = 0;
image(center_y-2, center_x+7) = 0;
image(center_y-3, center_x+7) = 0;
image(center_y-4, center_x+8) = 0;
image(center_y-5, center_x+9) = 0;
image(center_y-5, center_x+9) = 0;
image(center_y-6, center_x+9) = 0;
image(center_y-7, center_x+9) = 0;
image(center_y-8, center_x+8) = 0;
image(center_y-8, center_x+7) = 0;
image(center_y-7, center_x+6) = 0;
image(center_y-7, center_x+5) = 0;
image(center_y-7, center_x+4) = 0;
image(center_y-7, center_x+3) = 0;
image(center_y-8, center_x+2) = 0;
image(center_y-9, center_x+1) = 0;

% Now make the "dot"
if (mod(dot_size, 2) == 1)
    right_bound = floor(dot_size/2);
    left_bound = -1 * right_bound;
    for i=left_bound:right_bound
        for j=left_bound:right_bound
        image(center_y+i+1, center_x + distance + 6 + j) = 0;
        end
    end

else
    right_bound = dot_size/2;
    left_bound = -1 *(dot_size-1);
    for i=left_bound:right_bound
        for j=left_bound:right_bound
        image(center_y+i+1, center_x + distance + 6 + j) = 0;
        end
    end
end

end
