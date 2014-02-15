function [p,g] = regress_plane(x,y,z)

%[coeff,~,latent] = princomp([log(X(:)) log(Y(:)) log(means(:))]); %columns are coeffs to make eigenvector?

xm = mean(x); ym = mean(y); zm = mean(z);
M = [sum((x-xm).^2) , sum((x-xm).*(y-ym)) ; ...
     sum((x-xm).*(y-ym)) , sum((y-ym).^2) ];
d = [sum((x-xm).*(z-zm)); sum((y-ym).*(z-zm))];
p = M\d;
g = @(x,y) (zm + p(1)*(x-xm) + p(2)*(y-ym));