function guru_smarttext(lbl,x,y,y_crit,yfact)

if ~exist('yfact','var'), yfact = 1.25; end;
if ~iscell(lbl), lbl = {lbl}; end;

for li=1:length(lbl)
   if y_crit(li)
       text(0.9*x(li), (1/yfact)*y(li), lbl{li}, 'FontSize', 14);
   else
       text(0.9*x(li), yfact*y(li), lbl{li}, 'FontSize', 14);
   end;
end;
