function fig = de_newFig(figName, figType, varargin)
%

  if (~exist('figType','var'))
    figType = 'default';
  end;
  
  fig.name   = figName;
  fig.handle = figure;
  set(gca,'FontSize',18,'FontWeight','bold');
%  xlabel('', 'FontSize',24);
%  ylabel('', 'FontSize', 24);
  
  switch (figType)
    case 'default'
      pps = get(fig.handle,'PaperPosition');
      fig.size = pps(3:4);
      
    case '__img'
      imgSize = varargin{1};
      nPlots = varargin{2};
      [nRows,nCols] = guru_optSubplots(nPlots);
      fig.size     = imgSize(end:-1:1).*[nRows,nCols/1.25]/(1.5*norm([nRows,nCols]));

    case 'images'
      fig = guru_newFig(figName, '__img', varargin{1}.nInput, size(varargin{1}.X,2));

    case 'hu'
      fig = guru_newFig(figName, '__img', varargin{2}, varargin{1});
      
    case 'bars'
      [nRows,nCols] = guru_optSubplots(varargin{1});
      fig.size = [6+varargin{2}*0.4 12];

    otherwise
      error('Unknown fig type: %s', figType);
  end;