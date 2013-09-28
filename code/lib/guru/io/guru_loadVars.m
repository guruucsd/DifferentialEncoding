function varargout = guru_loadVar(fn, varargin)

  v = load(fn, varargin{:});
  
  for i=1:nargin-1
    varargout{i} = getfield(v, varargin{i});
  end;
