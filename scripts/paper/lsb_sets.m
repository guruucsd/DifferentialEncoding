function args = ben_sets(varargin)
%
%  Final shared settings for "ben's" runs

%  if (~ismember('runs', varargin)), args{end+1:end+2} = {'runs', 100
  args = {   'runs', 68, 'randState', 2,...
             'nHidden', 26, 'nConns', 100, 'out.plots', {'png'},  ...
             'plots', {'images','ffts'}, 'stats', {'ffts'}, ...
             'ac.errorType', 2, 'p.errorType', 2, 'errorType', 2, ...
             'ac.AvgError', 0, 'ac.MaxIterations', 1000, 'p.AvgError',  0, 'p.MaxIterations', 100 ...
         };


  % Remove any unwanted args
  j=1;
  while (j<=length(varargin))
    i=1;
    while (i<=length(args))
      if (strcmp(varargin{j}, args{i}));
        args{i+1} = varargin{j+1};
        varargin = varargin([1:(j-1) (j+2):end]);
        j=j-2;
        break;
      end;
      i=i+2;
    end;
    j=j+2;
  end;
  
  args = horzcat(args, varargin);
    
  
