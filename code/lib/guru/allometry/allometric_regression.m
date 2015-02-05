function [p, fns, rsquared, p_inv] = allometric_regression(x, y, xform, order, flip, figtype, est)
%function [p,fns] = allometric_regression(x,y,xform,order,flip,figtype)
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
    if ~iscell(x), 
        if size(x,1)==1, x=num2cell(x',1);
        else             x=num2cell(x,1); end;
    end;
    if ~iscell(y), 
        if size(y,1)==1, y=num2cell(y',1); 
        else             y=num2cell(y,1); end;
    end;
    if ~exist('xform','var'),   xform   = {'log' 'log'}; end;
    if ~exist('order','var'),   order   = 1; end;
    if ~exist('flip','var'),    flip    = false; end;
    if ~exist('figtype','var'), figtype = ''; %guru_iff(flip, '1', '3');
    elseif islogical(figtype),  figtype = guru_iff(figtype, '1', ''); % legacy
    end;
    if ~exist('est','var'), est = true; end;
    
    
    if ischar(xform), xform={xform}; end;
    if length(xform)==1, xform = {xform{1} xform{1}}; end;
    
    for ci=1:length(x)
        if length(x)==1, xt = xformfn(x{1}, xform{1});
        else,            xt = xformfn(x{ci},xform{1});
        end;
        
        if length(y)==1, yt = xformfn(y{1}, xform{2});
        else,            yt = xformfn(y{ci},xform{2});
        end;
        
%        yt = xformfn(y{ci},xform{2});

        if length(xt)>1
            p(ci,:) = polyfit(xt,yt,order);
            if order ~= 1
                error('RMA for non-order 1?  Impossible!  If needed, can revert back to polyfit, but ... show a warning?');
            end;
            p1 = mfe_rmaregress(xt,yt,[2, 2]); p1 = p1(end:-1:1);
            diff = (p1 - p(ci,:)) ./ (p1 + p(ci,:)) / 2;
            if any(abs(diff) > 0.05)
                fprintf('Differences between polyfit and rmaregress: [ %s]\n', sprintf('%5.1f%% ', diff*100));
            end;
            p(ci,:) = p1;
        else
            p(ci,:) = ones(order,1);
        end;
        fns(ci).reg    = @(x) polyval(p(ci,:),xformfn(x,xform{1}));
        fns(ci).xxform = @(d) (xformfn(d,xform{1}));
        fns(ci).yxform = @(d) (xformfn(d,xform{2}));
        fns(ci).xinv   = @(d) (xformfn(d,xform{1},'inv')); %inverse transform
        fns(ci).yinv   = @(d) (xformfn(d,xform{2},'inv'));
        fns(ci).y      = @(x) (fns(ci).yinv(fns(ci).reg(x)));
    end;
    
    
    % plot this thing
    %plot(xt, yt, 'o'); % scatter plot
    %hold on;
    %plot(xt, fns.reg(x));
    %legend({'Orig data',sprintf('regression [m=%f]', p(1)
    
    if flip==true
        [p_flp,fns_flp] = allometric_regression(y,x,xform(end:-1:1),order,false,'');
        p_inv = [1./p_flp(:,1) -p_flp(:,2)./p_flp(:,1)]; % show algebraic derivation of coeffs from inverse regression
    end;

    
    switch figtype
        case '1', 
            if flip
                f = figure; 
                set(f, 'Position', [16         297        1247         387]);
                subplot(1,2,1); allometric_plot1(x,y,p,    fns,    f,all(strcmp(xform,'log')));
                subplot(1,2,2); allometric_plot1(y,x,p_flp,fns_flp,f,all(strcmp(xform,'log')));
                subplot(1,2,1); %get back to first subplot
            else
                f = figure;
                allometric_plot1(x,y,p,fns,[],all(strcmp(xform,'log')));
            end;
        
        %
        case '2', allometric_plot2(x{1},y{1},p,fns,guru_iff(all(strcmp(xform,'log')), 'loglog', 'linear'));

        %
        case '3', allometric_plot2(x{1},y{1},p,fns,{'linear','loglog'});
            
        case '', ; % show no figure

        otherwise, error('Unknown figtype: %s', figtype);
    end;

    
    % compute residuals and r-squared
    resid = cell(size(x));
    rsquared = cell(size(x));
    for ci=1:length(x)
        rsquared{ci} = compute_rsquared(y{ci}, fns(ci).y(x{ci}));
        
        fprintf('rsquared: %.2f vs %.2f\n', rsquared{ci}, compute_rsquared(fns.yxform(y{ci}), fns.yxform(fns(ci).y(x{ci}))));
    end;

    % Compare to xxxx
    if est
        for di=1:length(x)
            [p1, ~, rsquared1] = allometric_regression_offset(x{di}, y{di});

            % Print the result
            fprintf('%6.4e + %6.4e * x.^%6.4f r^2 = %5.3f vs. %5.3f; \n', p1(end:-1:1), rsquared1, rsquared{1});
        end;
    end;    

function rsquared = compute_rsquared(y, yest)
    resid = y - yest;

    SSresid = sum(resid.^2);  % Square the residuals and total them obtain the residual sum of squares:
    SStotal = (length(y)-1) * var(y);  %Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:
    rsquared = 1 - SSresid/SStotal;  %Compute R2 using the formula given in the introduction of this topic:


function dt = xformfn(d,type,inv)
    if ~exist('inv','var'), inv=false;
    elseif ischar(inv), inv = true; end;

    if ~inv
        switch type
            case 'log',    dt = log10(d);
            case 'loglog', dt = log10(log10(d)); dt(imag(dt)~=0) = nan;
            case 'linear', dt=d;
            otherwise, error('?');
        end;

    else
        switch type
            case 'log', dt = 10.^(d);
            case 'loglog', dt = 10.^(10.^(d));
            case 'linear', dt=d;
            otherwise, error('?');
        end;
    end;
