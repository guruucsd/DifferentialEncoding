function H=grating2d(f,phi,theta,A,height,width)
% function to generate a 2D grating image
% f = frequency
% phi = phase
% theta = angle
% A = amplitude
% H=grating2d(f,phi,theta,A) 
% size of grating
  if (~exist('height','var')), height=100; end;
  if (~exist('width','var')),  width=100; end;

  wr=2*pi*f; % angular frequency
  wx=wr*cos(theta);
  wy=wr*sin(theta);
  H = zeros(height,width);
  for y=1:height
      for x=1:width
          H(y,x)=A*cos(wx*(x-width/2)+phi+wy*(y-height/2));
      end
  end
  