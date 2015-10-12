function rot_image = blob_stimuli(distance, dot_size, orientation)

%orientation is the follow values:
% 1 = blob on left
% 2 = blob rotated 72 degrees
% 3 = blob rotated 144 degrees
% 4 = blob rotated 216 degrees
% 5 = blob rotated 288 degrees

center_of_blob = [34, 15]; %hardcoded
image_height = 68;
image_width = 50;


image = ones(image_height, image_width);
rot_image = ones(image_height, image_width);

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

switch orientation
   case 1 % at the left
       rot_image = image;
       
       % Now make the "dot"
       if (mod(dot_size, 2) == 1)
           right_bound = floor(dot_size/2);
           left_bound = -1 * right_bound;
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+1, center_x + distance + 6 + j) = 0;
               end
           end
           
       else
           right_bound = dot_size/2;
           left_bound = -1 *(dot_size-1);
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+1, center_x + distance + 6 + j) = 0;
               end
           end
       end

       
   case 2 % 72 degrees
       image = image * -1 + 1; % invert for rotation
       rotated = imrotate(image, 72); 
       rot_image(:, :) = rotated(2:69, 11:60);
       rot_image = rot_image * -1 + 1; % invert again
       
       
       % Now make the "dot"
       center_y = 40; %hard-coded
       center_x = 33;
       if (mod(dot_size, 2) == 1)
           right_bound = floor(dot_size/2);
           left_bound = -1 * right_bound;
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i-distance, center_x+distance+j) = 0;
               end
           end
           
       else
           right_bound = dot_size/2;
           left_bound = -1 *(dot_size-1);
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i-distance, center_x+distance+j) = 0;
               end
           end
       end

       
   case 3  % 144 degrees
       image = image * -1 + 1;
       rot_image = imrotate(image, 144);
       rot_image = rot_image(4:71, 15:64);
       rot_image = rot_image * -1 + 1;
       center_y = 42;
       center_x = 31; % hard coded
       
       if (mod(dot_size, 2) == 1)
           right_bound = floor(dot_size/2);
           left_bound = -1 * right_bound;
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i-distance, center_x-distance+j) = 0;
               end
           end
           
       else
           right_bound = dot_size/2;
           left_bound = -1 *(dot_size-1);
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i-distance, center_x-distance+j) = 0;
               end
           end
       end
       
   case 4 % 216 degrees
       image = image * -1 + 1;
       rotated = imrotate(image, 216);
       rot_image(:, :) = rotated(14:81, 20:69);
       rot_image = rot_image * -1 + 1;
       
       center_y = 27;
       center_x = 25;
       
       if (mod(dot_size, 2) == 1)
           right_bound = floor(dot_size/2);
           left_bound = -1 * right_bound;
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+distance, center_x-distance+j) = 0;
               end
           end
           
       else
           right_bound = dot_size/2;
           left_bound = -1 *(dot_size-1);
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+distance, center_x-distance+j) = 0;
               end
           end
       end
       
       
       
   case 5 %288 degrees
       image = image * -1 + 1;
       rotated = imrotate(image, 288);
       rotated = rotated * -1 + 1;
       rot_image = rotated(1:68, 20:69);
       center_y = 32;
       center_x = 17;
       if (mod(dot_size, 2) == 1)
           right_bound = floor(dot_size/2);
           left_bound = -1 * right_bound;
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+distance, center_x+j) = 0;
               end
           end
           
       else
           right_bound = dot_size/2;
           left_bound = -1 *(dot_size-1);
           for i=left_bound:right_bound
               for j=left_bound:right_bound
                   rot_image(center_y+i+distance, center_x+j) = 0;
               end
           end
       end
       
   otherwise
        error('Invalid Orientation Number. Enter a number 1-5.');
end


end
