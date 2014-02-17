function new_model = de_CopyModelSettings(model, mi)

    new_model = guru_rmfield(model, 'p');  % creates a copy, due to MATLAB's lazy-pass-by-value procedure

    flds = { 'mu', 'sigma', 'nHidden', 'hpl', 'nConns', ...
               'ac.EtaInit', 'ac.Acc', 'ac.Dec', 'ac.lambda', ...
               'uberpath', 'out.dirstem', 'out.runspath' ...
    };

    for fi=1:length(flds)
        if ~guru_isfield(model, flds{fi}), continue; end;

        field_vals = guru_getfield(model, flds{fi}, NaN);

        if length(field_vals) == 1
            new_model = guru_setfield(new_model, flds{fi}, field_vals);
        elseif iscell(field_vals)
            new_model = guru_setfield(new_model, flds{fi}, field_vals{mi});
        else
            new_model = guru_setfield(new_model, flds{fi}, field_vals(mi));
        end;
    end;
