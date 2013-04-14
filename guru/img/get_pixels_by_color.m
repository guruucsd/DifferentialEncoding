function [ypix,xpix] = get_pixels_by_color(img, color, rotang)
  if ischar(img), img = imread(img); end;
  
  if ~exist('rotang','var'), rotang = 0; end;
  if rotang ~= 0, img = imrotate(img, rotang); end;
  
  if ischar(color)
      switch color
          case 'r', color=255*[1 0 0];
          case 'g', color=255*[0 1 0];
          case 'b', color=255*[0 0 1];
          case 'y', color=255*[1 1 0];
          case 'm', color=255*[1 0 1];
          case 'w', color=255*[1 1 1];
          case 'k', color=255*[0 0 0];
          otherwise, error('Unknown color: %s', color);
      end;
  % Make recursive call
  elseif iscell(color)
      ypix = cell(size(color)); 
      xpix = cell(size(color));
      for ci=1:numel(color)
          [ypix{ci},xpix{ci}] = get_pixels_by_color(img, color{ci}, rotang);
      end;
      return;
  end;

  
  [ypix,xpix] = ...
      find( img(:,:,1) == color(1) ...
          & img(:,:,2) == color(2) ...
          & img(:,:,3) == color(3) );
   
  
  
  if std(ypix)>std(xpix)
      [ypix,idx] = sort(ypix);
      xpix = xpix(idx);
  else
      [xpix,idx] = sort(xpix);
      ypix = ypix(idx);
  end;
  