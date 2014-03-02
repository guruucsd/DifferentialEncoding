function [nwm,ncc,nintra] = predict_nfibers(brwt, bvol, gmv, ndens, ccdens, cca, pct_proj)

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;
    if exist('gmv','var')      && isempty(gmv),      clear('gmv'); end;
    if exist('ndens','var')    && isempty(ndens),    clear('ndens'); end;
    if exist('ccdens','var')   && isempty(ccdens),   clear('ccdens'); end;
    if exist('cca','var')      && isempty(cca),      clear('cca'); end;
    if exist('pct_proj','var') && isempty(pct_proj), clear('pct_proj'); end;

    % send both weight and volume, it will pick the native one
    if ~exist('gmv','var') || isempty(gmv),          gmv      = predict_gmv(brwt, bvol); end;
    if ~exist('ndens','var') || isempty(ndens),      ndens    = predict_ndens(brwt, bvol); end;
    if ~exist('ccdens','var') || isempty(ccdens),    ccdens   = predict_cc_density(brwt, bvol); end;
    if ~exist('cca','var') || isempty(cca)           cca      = predict_cca(brwt, bvol); end;
    if ~exist('pct_proj','var') || isempty(pct_proj),pct_proj = predict_pct_proj(brwt, bvol); end;

    nneurons = 1E3*gmv.*ndens;
    nwm = pct_proj.*nneurons;
    ncc = 1E6*ccdens .* cca;
    nintra = nwm-ncc;
