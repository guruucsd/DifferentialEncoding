function f = guru_getfield(obj,fname)
%

    % recursive case: object is a cell array of objects
    if iscell(obj)
        f = cell(size(obj));
        for ci=1:numel(obj)
            f{ci} = guru_getfield(obj{ci},fname);
        end;
        %f = reshape([f{:}],size(obj));
        return;
        
    % recursive case: field name has dots
    elseif ~isempty(strfind(fname,'.'))
        idx = strfind(fname,'.');
        fname_cur = fname(1:idx(1)-1);
        fname_rest = fname(idx(1)+1:end);
        f = guru_getfield(obj.(fname_cur), fname_rest);
        
    % base case: have an object, field is found
    elseif isfield(obj,fname)
        f = obj.(fname);
        
    % base case: have an object, field not found
    else
        f = [];
    end;