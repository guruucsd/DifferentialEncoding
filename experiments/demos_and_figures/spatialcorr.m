function spatialcorr( img, sig, pt )
% Show how a grating, put within a receptive field (no surround inhibition)
% looks

  if (~exist('img','var'))
      imgsize = [25 25];
  else
      imgsize = size(img);
  end;

  if (~exist('pt','var'))
      pt = round(imgsize/2);
  end;

  if (~exist('img','var'))
      img = 0.5*ones(imgsize);
      nloops = 1;
      freq = .15;  %hsf: .25; lsf: .05
      for ii=1:nloops
          img = img + mfe_grating2d(freq, 0, pi*ii/nloops, 0.5/nloops, size(img,1), size(img,2));
      end;
  end;
  if (~exist('sig','var'))
      sig = min(size(img))*[1 1];
  end;

  d = zeros(size(img));
  for ii=1:numel(img)
      [x1,x2] = ind2sub(size(img), ii);
      d(ii) = img(pt(1),pt(2)) * img(ii) * mvnpdf([x1 x2], pt, sig);
  end;

  figure;
  set(gcf,'position',[45           8        1125         676]);

  subplot(1,3,1);
  colormap('gray');
  imagesc(img); hold on;
  plot(pt(1),pt(2),'*g');
  axis image; axis equal; axis tight; set(gca, 'xtick',[],'ytick',[]);
  mfe_freezeColors;

  subplot(1,3,2);
  colormap('gray');
  imagesc(d); hold on;
  plot(pt(1),pt(2),'*g');
  axis image; axis equal; axis tight; set(gca, 'xtick',[],'ytick',[]);
  mfe_freezeColors;

  subplot(1,3,3);
  colormap('jet');
  [Y,X] = meshgrid(1:imgsize(1), 1:imgsize(2));
  surf(X,Y,d); hold on;
  plot3(pt(1),pt(2),d(pt(1),pt(2)),'*g');
  axis tight; set(gca, 'xtick',[],'ytick',[],'ztick',[]);
  mfe_freezeColors;

  mfe_unfreezeColors;
