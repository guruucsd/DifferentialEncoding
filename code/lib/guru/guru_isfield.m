function f = guru_isfield(d, fn)

    % Loop through cell arrays and do a recursive call
    if iscell(d)
        f = cell(length(d),1);

        for di=1:length(d)
            f{di} = guru_isfield(d{di}, fn);
        end;
        return;
    end;

    % BASE CASE: if field name has no dots, just return the field!
    dotidx = findstr('.',fn);
    if isempty(dotidx)
        f = isfield(d, fn);
    % If field name has dots, then do recursive call
    else
        fieldnames = mfe_split('.',fn,2);
        if ~isfield(d, fieldnames{1})
            f = false;
        else
            f = guru_isfield(d.(fieldnames{1}), fieldnames{2});
        end;
    end;


