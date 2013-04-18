function [ypix,xpix] = get_pixels_by_color(img, color, rotang, tol)
  if ischar(img), img = imread(img); end;
  
  if ~exist('rotang','var'), rotang = 0; end;
  if ~exist('tol','var'),    tol = 0; end;
  
  if iscell(color)
      ypix = cell(size(color)); 
      xpix = cell(size(color));
      for ci=1:numel(color)
          [ypix{ci},xpix{ci}] = get_pixels_by_color(img, color{ci}, rotang, tol);
      end;
      return;
  end;

  [ypix,xpix] = find( get_img_by_color(img, color, rotang, tol) );
   
  if std(ypix)>std(xpix)
      [ypix,idx] = sort(ypix);
      xpix = xpix(idx);
  else
      [xpix,idx] = sort(xpix);
      ypix = ypix(idx);
  end;
  