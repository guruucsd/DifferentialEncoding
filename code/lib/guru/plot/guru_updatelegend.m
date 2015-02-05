function guru_updatelegend(ax, legidx, legtext)
% update an entry in the legend
% 
% lh = legend(ax);
% ch = get(lh,'Children');
% th = findobj(ch,'Type','text');
% set(th(end-legidx+1), 'String', legtext)

[lh,~,outh,outm] = legend(ax);
outm{legidx} = legtext;

legend( outh, outm, 'Location', get(lh,'Location') );