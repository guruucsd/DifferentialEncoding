function reg_txt = guru_poly2text(p,varname)
%function reg_txt = guru_poly2text(p)
% Takes polynomial coefficients (a la polyfit), and returns
% a string equation from them
%
% p: polynomial coefficients (highest order first)
% varname: string representing variable in equation; ('X' by default)
%
% reg_text: string representing polynomial equation


if ~exist('varname','var'), varname = 'x'; end;

reg_txt = sprintf('%4.2f',p(end));
for oi=length(p)-1:-1:1
    if (length(p)-oi) == 1, cur_term = sprintf('%4.2f%s', p(oi), varname);
    else,                   cur_term = sprintf('%4.2f%s^%d',p(oi), varname, length(p)-oi);
    end;

    if p(oi+1)<0,           reg_txt  = [cur_term reg_txt];
    else,                   reg_txt  = [cur_term ' + ' reg_txt];
    end;    
end;
