function loop_analyze(trn, tst, plt, dbg)
%

if ~exist('plt','var'), plt = {'all'}; end;
if ~exist('dbg','var'), dbg = []; end;

fn = loop_collect_data(trn, tst);
loop_plot_data(fn, plt, dbg);
if exist(fn,'file'), fprintf(['rm -f ' fn]); end;
