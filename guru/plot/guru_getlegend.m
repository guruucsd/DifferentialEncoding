function leg = guru_getlegend(ax)

lh = legend(ax);
ch = get(lh,'Children');
th = findobj(ch,'Type','text');

leg = cell(size(th));
for ti=1:numel(th)
    leg{ti} = get(th(ti),'String');
end;
