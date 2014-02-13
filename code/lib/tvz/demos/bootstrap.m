function yb=bootstrap(y)
% BOOTSTRAP Return a bootstrapped sample from the data vector y
yb = sort(y([fix(rand(length(y),1)*length(y)) + 1]));
