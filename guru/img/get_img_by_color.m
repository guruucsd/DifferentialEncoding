function [cimg] = get_img_by_color(img, color, rotang, tol)
  if ischar(img), img = imread(img); end;
  
  if ~exist('rotang','var'), rotang = 0; end;
  if ~exist('tol','var'),    tol = 0; end;
  
  if rotang ~= 0, img = imrotate(img, rotang); end;
  
  % Translate string to colors
  if ischar(color)
      switch color
          case 'r', color=[1 0 0];
          case 'g', color=[0 1 0];
          case 'b', color=[0 0 1];
          case 'y', color=[1 1 0];
          case 'm', color=[1 0 1];
          case 'w', color=[1 1 1];
          case 'k', color=[0 0 0];
          otherwise, error('Unknown color: %s', color);
      end;
      
  % Make recursive call
  elseif iscell(color)
      ypix = cell(size(color)); 
      xpix = cell(size(color));
      for ci=1:numel(color)
          [ypix{ci},xpix{ci}] = get_pixels_by_color(img, color{ci}, rotang, tol);
      end;
      return;
  end;

  color = double(color);
  img   = double(img)/255;
  
  [cimg] = ((abs(img(:,:,1) - color(1)) <= tol) ...
          & (abs(img(:,:,2) - color(2)) <= tol) ...
          & (abs(img(:,:,3) - color(3)) <= tol));
