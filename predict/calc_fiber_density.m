function dens = calc_fiber_density(d_mye,p_mye,d_unmye, p_unmye, pct_mye, ff)
%
% d: diameters
% p: proportion
% ff: filling fraction

if ~exist('ff','var'), ff = 0.87; end; % from wang

unmye_areas = pi*(d_unmye/2).^2;
mye_areas   = pi*(d_mye./2/0.7).^2; %0.7 = average g-ratio

%fprintf('Sums: prop_unmye: %f, prop_mye: %f, pct_mye: %f\n', sum(p_unmye), sum(p_mye), pct_mye);
dens = ff/((1-pct_mye)*sum(unmye_areas.*p_unmye) + pct_mye*sum(mye_areas.*p_mye));