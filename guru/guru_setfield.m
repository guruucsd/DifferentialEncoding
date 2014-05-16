function f = guru_setfield(d, fn, val)
    % Loop through cell arrays and do a recursive call
    if iscell(d)
        f = cell(length(d),1);

        for di=1:length(d)
            f{di} = guru_setfield(d{di}, fn, val);
        end;
        return;
    end;

    % BASE CASE: if field name has no dots, just return the field!
    dotidx = findstr('.',fn);
    f = d;

    if isempty(dotidx)
        f.(fn) = val;

    % If field name has dots, then do recursive call
    else
        fieldnames = mfe_split('.', fn, 2);
        if ~isfield(f, fieldnames{1})
            f.(fieldnames{1}) = struct()
        end;

        f.(fieldnames{1}) = guru_setfield(f.(fieldnames{1}), fieldnames{2}, val);
    end;


