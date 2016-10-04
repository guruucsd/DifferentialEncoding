function filout = pruning_analyze(trn, tst, plt, dbg)
%

if ~exist('plt','var'), plt = {'all'}; end;
if ~exist('dbg','var'), dbg = []; end;

% Collect data
fns = pruning_collect_data(trn, tst);



%% Play!!
lf = load(fns{1});
hf = load(fns{2});

lf.bars = permute(reshape(cell2mat(lf.perf)', [2 size(lf.perf)]), [2 3 1]);
lf.bars_diff = diff(lf.bars,[],3);

hf.bars = permute(reshape(cell2mat(hf.perf)', [2 size(hf.perf)]), [2 3 1]);
hf.bars_diff = diff(hf.bars,[],3);

asymm_fact = (lf.bars_diff - hf.bars_diff)./(lf.bars_diff+hf.bars_diff)/2


% low freq
loop_plot_data(fns{1}, plt, dbg);

% high freq
loop_plot_data(fns{2}, plt, dbg);

pruning_plot_data(fns, plt, dbg);

if exist(fns{1},'file'), fprintf('rm -f %s\n', fns{1}); end;
if exist(fns{2},'file'), fprintf('rm -f %s\n', fns{2}); end;
