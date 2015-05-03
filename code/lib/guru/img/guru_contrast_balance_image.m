function [ return_image ] = guru_contrast_balance_image( image, border_width, new_bg_color, fg_color, eight_neighbors )
%
% Inputs:
%   image           : 2D matrix of binary pixels
%   border_width    : optional, # of pixels to fill from foreground.
%   new_bg_color    : optional, background color after CB (default: image
%   mean)
%   fg_color        : optional, 0 or 1 (default: 1)
%   eight_neighbors : optional, whether to use 4 or 8 neighbors (default: true)
%
% Outputs:
%   return_image    : contrast-balanced image, of same size as image.

all_colors = unique(image(:));
guru_assert(length(all_colors) == 2, 'Input must be a binary image');

if ~exist('border_width', 'var'), border_width = 1; end;
if ~exist('new_bg_color', 'var'), new_bg_color = mean(image(:)); end;
if ~exist('fg_color', 'var'), fg_color = max(image(:)); end;
if ~exist('eight_neighbors', 'var'), eight_neighbors = true; end;

bg_color = setdiff(all_colors, fg_color);
[height, width] = size(image);

return_image = new_bg_color * ones(size(image));

for ii = 1:height
  for ij = 1:width
    if image(ii, ij) == fg_color
      return_image(ii, ij) = fg_color;
      continue;
    end
    
    for ik = 1:border_width
      if (ii-ik) > 0 && image(ii-ik, ij) == fg_color
          return_image(ii, ij) = bg_color;

      elseif (ii+ik) <= height && image(ii + ik, ij) == fg_color
          return_image(ii, ij) = bg_color;
          
      elseif (ij-ik) > 0 && image(ii, ij-ik) == fg_color
          return_image(ii, ij) = bg_color;

      elseif (ij+ik) <= width && image(ii, ij+ik) == fg_color
          return_image(ii, ij) = bg_color;

      elseif eight_neighbors
          for il=1:border_width
              if (ii-ik > 0) && (ij-il > 0) && image(ii-ik, ij-il) == fg_color
                  return_image(ii, ij) = bg_color;

              elseif (ii-ik > 0) && (ij+il <= width) && image(ii-ik, ij+il) == fg_color
                  return_image(ii, ij) = bg_color;

              elseif (ii+ik <= height) && (ij-il > 0) && image(ii+ik, ij-il) == fg_color
                  return_image(ii, ij) = bg_color;

              elseif (ii+ik <= height) && (ij+il <= width) && image(ii+ik, ij+il) == fg_color
                  return_image(ii, ij) = bg_color;

              end
          end;
      end
    end
  end
end
