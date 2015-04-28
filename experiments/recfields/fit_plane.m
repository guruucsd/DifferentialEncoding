function [p,g] = fit_plane(x,y,z)
% Given x,y, find parameters to estimate z.
%
% Returns:
%   p: parameters of fit
%   g: function that, given x,y will output predicted z.

xm = mean(x); ym = mean(y); zm = mean(z);
M = [sum((x-xm).^2) , sum((x-xm).*(y-ym)) ; ...
     sum((x-xm).*(y-ym)) , sum((y-ym).^2) ];
d = [sum((x-xm).*(z-zm)); sum((y-ym).*(z-zm))];
p = M\d;
g = @(x,y) (zm + p(1)*(x-xm) + p(2)*(y-ym));