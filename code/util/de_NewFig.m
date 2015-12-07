function fig = de_NewFig(varargin)
%function fig = de_NewFig(varargin)
%
% Initializes a new figure object with a handle, size, position, and title.

  % Snip off figure
  if (ischar(varargin{1}) ...
      && strcmp(varargin{1}, 'dummy'))
      fig = struct('handle', [], 'name', [], 'size', [], 'cached', []);
      fig = fig([]);
      return;

  elseif (isempty(varargin))
      fig.handle = figure;
      varargin = {'default'};

  elseif ischar(varargin{1})
      fig.handle = figure;

  else
      fig.handle = varargin{1};
      varargin = varargin(2:end);
  end;

  % Parse off expected values
  figName = varargin{1};  varargin = varargin(2:end);
  if (isempty(varargin))
      figType = 'default';
  else,  figType = varargin{1}; varargin=varargin(2:end);
  end;



  fig.name   = figName;
  set(gca,'FontSize',18,'FontWeight','bold');

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
      fig = de_NewFig(fig.handle, figName, '__img', varargin{1}.nInput, size(varargin{1}.X,2));

    case 'hu'
      fig = de_NewFig(fig.handle, figName, '__img', varargin{2}, varargin{1});

    case 'bars'
      [nRows,nCols] = guru_optSubplots(varargin{1});
      fig.size = [6+varargin{2}*0.4 12];

    otherwise
      error('Unknown fig type: %s', figType);
  end;

  if (~isfield(fig, 'cached')), fig.cached = 0; end;