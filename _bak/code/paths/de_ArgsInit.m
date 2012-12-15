function args = de_ArgsInit(args, varargin)

  % Remove any unwanted args
  j=1;
  while (j<=length(varargin))
  
    % Find the arg in args, and remove it
    i=1;
    while (i<=length(args))
      if (strcmp(varargin{j}, args{i}));
        % Remove arg
        if (isempty(varargin{j+1}))
          args = args([1:(i-1) (i+2):end]);
          i = i - 2; % reindex so we're not off the end
          
        % Use specified arg value 
        else
          args{i+1} = varargin{j+1};
        end;
        break;
      end;
      
      i=i+2;
    end;
    
    % Not found; add it
    if (i>length(args) && ~isempty(varargin{j+1}))
      args{end+1} = varargin{j};
      args{end+1} = varargin{j+1};
    end;
    
    j = j + 2;
  end;
