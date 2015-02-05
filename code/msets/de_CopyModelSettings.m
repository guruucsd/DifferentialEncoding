function new_model = de_CopyModelSettings(model, mi)

    new_model = guru_rmfield(model, 'p');  % creates a copy, due to MATLAB's lazy-pass-by-value procedure

    flds = { 'mu', 'sigma', 'nHidden', 'hpl', 'nConns', 'distn', ...
               'ac.EtaInit', 'ac.Acc', 'ac.Dec', 'ac.lambda', ...
               'uberpath', 'out.dirstem', 'out.runspath' ...
    };
    for fi=1:length(flds)
        if ~guru_isfield(model, flds{fi}), continue; end;

        field_vals = guru_getfield(model, flds{fi}, NaN);

        if iscell(field_vals)
            if length(field_vals) == 1
                cur_val = field_vals{1};
            else
                cur_val = field_vals{mi};
            end;
        elseif length(field_vals) == 1
            cur_val = field_vals;
        else
            cur_val = field_vals(mi);
        end;

        new_model = guru_setfield(new_model, flds{fi}, cur_val);
    end;

