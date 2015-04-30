function [ return_image ] = guru_contrast_balance_image( image, fg_color, eight_neighbors, border_width )
%
% Inputs:
%   image           : 2D matrix of binary pixels
%   fg_color        : optional, 0 or 1 (default: 1)
%   eight_neighbors : optional, whether to use 4 or 8 neighbors (default: true)
%   border_width    : optional, # of pixels to fill from foreground.
%
% Outputs:
%   return_image    : contrast-balanced image, of same size as image.

if ~exist('fg_color', 'var'), fg_color = 1; end;
if ~exist('eight_neighbors', 'var'), eight_neighbors = true; end;
if ~exist('border_width', 'var'), border_width = 1; end;

bg_color = 1 - fg_color;
[height, width] = size(image);
total_color = 0;

for ii = 1:height
  for ij = 1:width
    total_color = total_color + image(ii, ij);
    if image(ii, ij) == fg_color
      continue;
    end
    for ik = 1:border_width
      if (ii-ik) > 0
          if image(ii-ik, ij) == fg_color
              image (ii, ij) = 0.5;
              continue;
          end
      end
      if (ii+ik) <= height
          if image(ii + ik, ij) == fg_color
              image (ii, ij) = 0.5;
              continue;
          end
      end
      if (ij-ik) > 0
          if image(ii, ij-ik) == fg_color
              image (ii, ij) = 0.5;
              continue;
          end
      end
      if (ij+ik) <= width
          if image(ii, ij+ik) == fg_color
              image(ii, ij) = 0.5;
              continue;
          end
      end
      if eight_neighbors == 1
          for il = 1:border_width
              if (ii-ik > 0) && (ij-il > 0)
                  if image(ii-ik, ij-il) == fg_color
                      image(ii, ij) = 0.5;
                      continue;
                  end
              end
              if (ii-ik > 0) && (ij+il <= width)
                  if image(ii-ik, ij+il) == fg_color
                      image(ii, ij) = 0.5;
                      continue;
                  end
              end
              if (ii+ik <= height) && (ij-il > 0)
                  if image(ii+ik, ij-il) == fg_color
                      image(ii, ij) = 0.5;
                      continue;
                  end
              end
              if (ii+ik <= height) && (ij+il <= width)
                  if image(ii+ik, ij+il) == fg_color
                      image(ii, ij) = 0.5;
                      continue;
                  end
              end
          end

      end

    end

  end

end

average_color = total_color / (height * width);

for ii=1:height
    for ij=1:width
        if image(ii, ij) == bg_color
            image(ii, ij) = average_color;
        elseif image(ii, ij) == 0.5
            image(ii, ij) = bg_color;
        end
    end
end
return_image = image;
end
