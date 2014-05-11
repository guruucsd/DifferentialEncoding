function [p,fns,rsq] = allometric_regress(x,y,xform,order,flip,figtype)
%function [p,fns] = allometric_regress(x,y,xform,order,flip,figtype)

    if ~exist('xform','var'),   xform   = {'log' 'log'}; end;
    if ~exist('order','var'),   order   = 1; end;
    if ~exist('flip','var'),    flip    = false; end;
    if ~exist('figtype','var'), figtype = ''; %guru_iff(flip, '1', '3');
    elseif islogical(figtype),  figtype = guru_iff(figtype, '1', ''); % legacy
    end;

    [p,fns,rsq] = allometric_regression(x,y,xform,order,flip,figtype);
