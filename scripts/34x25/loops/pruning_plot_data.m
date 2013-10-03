function loop_plot_data(fn, plt, dbg)

if ~exist(fn,  'file'), error('could not find filename %s', fn); end;
if ~exist('plt','var'), plt = {'all'}; end;
if ~ismember(1,dbg), dbg = []; end;

load(fn);

%%========================
% Manipulate data
%=========================

% Sergent task
if length(perf{1})==2
    bars = permute(reshape(cell2mat(perf)', [2 size(perf)]), [2 3 1]);
    bars_diff = diff(bars,[],3);
    
elseif length(perf{1})==1
    bars_diff = cell2mat(perf);
else
    error('unknown perf data');
end;

%%========================
% Plot data
%=========================


% Image representing interaction
if ismember('bars_img',plt) || ismember('all',plt)
end;







if ismember(1,dbg)
  keyboard;
end;



function yv = lin_interp(x,y,xv)
    idx1 = find(x<=xv,1,'last');
    idx2 = find(x>xv,1,'first');
    x1 = x(idx1);
    x2 = x(idx2);
    y1 = y(idx1);
    y2 = y(idx2);
    
    yv = y1 + (xv-x1)*(y2-y1)/(x2-x1);