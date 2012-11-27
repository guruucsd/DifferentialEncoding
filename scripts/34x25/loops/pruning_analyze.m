function filout = pruning_analyze(trn, tst, plt, dbg)
%

if ~exist('plt','var'), plt = {'all'}; end;
if ~exist('dbg','var'), dbg = []; end;

fn = pruning_collect_data(trn, tst);
loop_analyze_data(fn, plt, dbg);
if exist(fn,'file'), fprintf(['rm -f ' fn]); end;
