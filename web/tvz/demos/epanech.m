function k=epanech(t)
% EPANECH The Epanechnikov kernel takes arguments between -sqrt(5) and sqrt(5).
% All other values return 0.
k=(abs(t)<sqrt(5)).*(.75.*(1.-0.2.*t.^2)/sqrt(5));
