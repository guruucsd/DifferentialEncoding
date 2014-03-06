function d = IUBDpmf(x,p1,p2)
d = (diff([0 IUBDcdf([x(1:end-1) 10], p1, p2)]));
