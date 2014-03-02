function [nareas, nareaconns] = predict_nareas(brwt, bvol)

global g_nareas g_nareaconns

% convert to native units
if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;

if isempty(g_nareas) || true
    g_nareas.y = @(bvol) 15.8*(bvol).^0.31; % Changizi & Shimojo, Fig1c
    %p_areaconns = [2.04 0.34] % changizi & shimojo, Fig. 3a
    g_nareaconns.y = @(bvol) (0.34*g_nareas.y(bvol).^2.04); % changizi & shimojo, Fig. 3a
    %g2_areaconns = @(bvol) (4.11*bvol.^0.31);    % changizi & shimojo, Fig. 3b
end;

nareas     = g_nareas.y(bvol);
nareaconns = g_nareaconns.y(bvol)./nareas;
