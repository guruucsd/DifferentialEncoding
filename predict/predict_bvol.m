function bvol = predict_bvol(bwt)

global p g_vol

if isempty(g_vol)
    %% Convert weights to volumes
    wts = [1350 420 500 370 92 22]'; % http://faculty.washington.edu/chudler/facts.html
    vols = [1298 337 383 407 79 23]'; %rilling & insel, 1999

    [~,g_vol] = allometric_regression(wts,  vols);
end;
bvol = g_vol.y(bwt);