function [ncc] = predict_ncc_fibers(brwt, bvol, gmv, ndens, ccdens, cca)

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;
    if ~exist('gmv','var')    , gmv = []; end;
    if ~exist('ndens','var')  , ndens = []; end;%&& isempty(ndens),  clear('ndens'); end;
    if ~exist('ccdens','var') , ccdens = []; end;%&& isempty(ccdens), clear('ccdens'); end;
    if ~exist('cca','var')    , cca = []; end;%&& isempty(cca),    clear('cca'); end;

    [~,ncc] = predict_nfibers(brwt, bvol, gmv, ndens, ccdens, cca);

