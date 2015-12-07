function varargout = guru_loadVars(fn, varargin)

  v = load(fn, varargin{:});
  
  for ii=1:nargin-1
    varargout{ii} = getfield(v, varargin{ii});
  end;
