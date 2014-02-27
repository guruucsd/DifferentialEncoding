function args = de_ArgsInit(varargin)
% Remove any unwanted args

  args = {};
  if (mod(length(varargin),2)~=0)
    error('args must have an even length');
  end;

  % Remove any unwanted args
  jj=1;
  while (jj<=length(varargin))

    % Find the arg in args, and remove it
    ii=1;
    while (ii<=length(args))
      if (strcmp(varargin{jj}, args{ii}));
        % Remove arg
        if (isempty(varargin{jj+1}))
          args = args([1:(ii-1) (ii+2):end]);
          ii = ii - 2; % reindex so we're not off the end

        % Use specified arg value
        else
          args{ii+1} = varargin{jj+1};
        end;
        break;
      end;

      ii=ii+2;
    end;

    % Not found; add it
    if (ii>length(args) && ~isempty(varargin{jj+1}))
      args{end+1} = varargin{jj};
      args{end+1} = varargin{jj+1};
    end;

    jj = jj + 2;
  end;
