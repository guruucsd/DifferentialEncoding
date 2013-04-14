function [p,fns] = allometric_regression(x,y,xform,order,flip,figtype)
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
        [p_flp,fns_flp] = allometric_regression(y,x,xform,order,false,'');
        p_inv = [1./p_flp(:,1) -p_flp(:,2)./p_flp(:,1)] % show algebraic derivation of coeffs from inverse regression
    end;

    
    switch figtype
        case '1', 
            if flip
                f = figure; 
                set(f, 'Position', [16         297        1247         387]);
                subplot(1,2,1); allometric_plot1(x,y,p,    fns,    f,all(strcmp(xform,'log')));
                subplot(1,2,2); allometric_plot1(x,y,p_flp,fns_flp,f,all(strcmp(xform,'log')));
            else
                f = figure;
                allometric_plot1(x,y,p,fns,[],all(strcmp(xform,'log')));
            end;
        
        %
        case '2', allometric_plot2(x{1},y{1},p,fns,guru_iff(all(strcmp(xform,'log')), 'loglog', 'linear'));

        %
        case '3', allometric_plot2(x{1},y{1},p,fns,{'linear','loglog'});
            
        case '', ;

        otherwise, error('Unknown figtype: %s', figtype);
    end;

    
    
    
function dt = xformfn(d,type,inv)
    if ~exist('inv','var'), inv=false;
    elseif ischar(inv), inv = true; end;

    if ~inv
        switch type
            case 'log', dt = log10(d);
            case 'linear', dt=d;
            otherwise, error('?');
        end;

    else
        switch type
            case 'log', dt = 10.^(d);
            case 'linear', dt=d;
            otherwise, error('?');
        end;
    end;
