function [p,g] = fit_exp_decay(x,y,guess, showfig)

if ~exist('guess','var'), guess=100*rand([1 3]); end;
if ~exist('showfig','var'), showfig = true; end;

p = fminsearch(@(p) norm(y - (exp(-(x+p(1))./p(2)) + p(3))), guess);
g = @(x) p(3)+exp( (-(x+p(1))/p(2)));



if showfig
    figure; 
    semilogx(x, y, 'o'); hold on; 
    semilogx(linspace(x(1), x(end),100), g(linspace(x(1), x(end), 100)));
end;