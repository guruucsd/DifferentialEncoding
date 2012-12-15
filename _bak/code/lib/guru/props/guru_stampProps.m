function mSets = guru_stampProps(mSets, varargin)
  
  for i=1:2:length(varargin)
    prop = varargin{i};
    val  = varargin{i+1};
    
    % Make sure cell-like properties are cells
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
  