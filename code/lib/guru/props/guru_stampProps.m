function mSets = guru_stampProps(varargin)

  % No input, can only return empty output
  if (isempty(varargin))
    mSets = struct();
    error('No input arguments')
  end;

  % Odd # of inputs; grab original object, and expect strings at every second input
  if (1==mod(length(varargin),2))
    if (isstruct(varargin{1}))
      mSets = varargin{1};
      varargin = varargin(2:end);
    elseif (ischar(varargin{1}))
      error('Must pass in arg/val pairs; found odd # of input args');
    else
      error('First arg must be an object (to stamp props on) or a string (prop name for next value)');
    end;

  % Even # of inputs; start with emtpy object
  else
    mSets = struct();
  end;

  % expect strings at every second input
  for pi=1:2:length(varargin)
    prop = varargin{pi};
    val  = varargin{pi+1};
    
    % Make sure cell-like properties are cells
    if (~ischar(prop))
      error('arg # %d is not a prop name', pi);
    end;

    switch (prop)
      case {'plots','stats'}
        if (ischar(val))
          val = {val};
        end;
    end;
    
    % set on object
    parts = mfe_split('.', prop);
    switch (length(parts))
        case 1, mSets.(parts{1}) = val;
        case 2, mSets.(parts{1}).(parts{2}) = val;
        case 3, mSets.(parts{1}).(parts{2}).(parts{3}) = val;
        case 4, mSets.(parts{1}).(parts{2}).(parts{3}).(parts{4}) = val;
        case 5, mSets.(parts{1}).(parts{2}).(parts{3}).(parts{4}).(parts{5}) = val;
        otherwise, error('parts depth too great; copy-paste more, you hack!');
    end;
  end;
  