function gmt = predict_gm_thickness(brwt,bvol)
% Function for computing grey matter thickness from brain volume
%g_gmt = @(v) 10.^polyval([1/9 0], log10(v));

    global g_gmt;

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;

    if isempty(g_gmt) || true
        g_gmt.y = @(bvol) 10*(0.026 * log(bvol) + 0.084);
    end;

    gmt = g_gmt.y(bvol);
    