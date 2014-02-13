function f = guru_getfield(d, fn, varargin)

    % Loop through cell arrays and do a recursive call
    if iscell(d)
        f = cell(length(d),1);
    
        for di=1:length(d)
            f{di} = guru_getfield(d{di}, fn, varargin{:});
        end;
        return;
    end;
    
    % BASE CASE: if field name has no dots, just return the field!
    dotidx = findstr('.',fn);
    if isempty(dotidx)
        if isfield(d, fn) || isempty(varargin)
            % Either get the value (it exists), or error ('cause there's no default)
            f = d.(fn);
        else
            f = varargin{1};
        end;
    % If field name has dots, then do recursive call
    else
        fieldnames = mfe_split('.',fn,2);
        f = guru_getfield(guru_getfield(d,fieldnames{1}, varargin{:}), fieldnames{2}, varargin{:});
    end;
        
        
