function o = guru_rmfield(o,fld)
%

    if (isfield(o,fld))
        o = rmfield(o,fld);
    end;