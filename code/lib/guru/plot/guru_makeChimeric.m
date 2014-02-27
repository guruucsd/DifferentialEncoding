function [img] = guru_makeChimeric(img, side)
%
%

  switch(side)
    case {'l', 'left'}
      nPix = size(img,2);

      % Even; duplicate all points
      if (mod(nPix,2)==0)
        endpt = nPix/2;
        img(:,endpt+1:end) = img(:,endpt:-1:1);

      % Odd; duplicate all but meridian
      else
        endpt = (nPix-1)/2;
        img(:,endpt+2:end) = img(:, endpt:-1:1);
      end;

    case {'r', 'right'}
      nPix = size(img,2);

      % Even; duplicate all points
      if (mod(nPix,2)==0)
        endpt = nPix/2;
        img(:,endpt:-1:1) = img(:,endpt+1:end);

      % Odd; duplicate all but meridian
      else
        endpt = (nPix-1)/2;
        img(:, endpt:-1:1) = img(:,endpt+2:end);
      end;

    otherwise
      error('Unknown side: %s', side);
  end;