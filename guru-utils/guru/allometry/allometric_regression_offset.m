function [p, fns, rsquared] = allometric_regression_offset(x, y)
%function [p,fns] = allometric_regression(x,y)
%
% x:
% y:
% xform: log, linear (1d to apply to x and y; 2d to do differently)
% order: order of polynomial fit (linear=1; default=1)
% flip: regress inverse relationship (and algebraically derive these
% coefficients), to assess reliability
% figtype: plot result?
%
% p: coeffs
% rfn: regression function
% tfn: transform function
%
% rv usage:
% plot(tfn(x), tfn(y), 'o'); %data
% hold on;
% plot(tfn(x), rfn(x)); %regression line
%


    eu_dist = @(x,y) sqrt(sum((x(:) - y(:)).^2));
    offset_log_fn = @(p, x) p(3) + p(2) * x.^p(1);
    cost_fn = @(p) eu_dist(y, offset_log_fn(p, x));
    safety_cost_fn = @(p) cost_fn(p) + 1E50 * sum((0 > offset_log_fn(p, x)) .* -offset_log_fn(p, x));

    % initialize through allometric regressions
%    function [p, fns, rsquared, p_inv] = allometric_regression(x, y, xform, order, flip, figtype, est)
    
    plog = allometric_regression(x, y, 'log', 1, false, '', false);
    plinear = allometric_regression(x, y, 'linear', 1, false, '', false);
    pinit = [plog(1) 10.^plog(2) plinear(2)];
    p = fminsearch(cost_fn, pinit, optimset('MaxFunEvals', 1E10, 'MaxIter', 1E8));

    fns.reg = @(x) p(3) + p(2) * x.^p(1);
    fns.xinv = @(x) x;
    fns.yinv = @(y) y;
    fns.xxform = @(x) x;
    fns.yxform = @(y) y;
    fns.y = @(x) fns.yinv(fns.reg(x));

    % compute residuals and r-squared
    resid = y - fns.y(x);
    SSresid = sum(resid.^2);  % Square the residuals and total them obtain the residual sum of squares:
    SStotal = (length(y)-1) * var(y);  %Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:
    rsquared = 1 - SSresid/SStotal;  %Compute R2 using the formula given in the introduction of this topic:

    % get true offset

%    fns(ci).reg    = @(x) polyval(p(ci,:),xformfn(x,xform{1}));
%    fns(ci).xxform = @(d) (d);
%    fns(ci).yxform = @(d) (d);
%    fns(ci).xinv   = @(d) (d); %inverse transform
%    fns(ci).yinv   = @(d) (d);
%    fns(ci).y      = @(x) (fns(ci).yinv(fns(ci).reg(x)));
