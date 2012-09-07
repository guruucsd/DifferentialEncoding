%  Loop through a bunch of sigma values,
%    then produce a tex table of the results.

args = depp_2D_args('plots', {'connectivity'}, ...
                 'stats', {'none'}, ...
                 'sigma', []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GATHER DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist('allstats.mat','file'))
  load('allstats.mat');
else
  s1=[2:13];
  s2=[25:-1:14];

  allstats = cell(size(s1));

  for i=1:length(s1)
    args = {args{:} 'sigma', [s1(i) s2(i)]};
    
    [j1,j2,allstats{i}] = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
  end;

  save('allstats','allstats', 's1','s2');
  boobies
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMP TO LATEX TABLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigmas     = zeros(length(s1),2);
ls_bars    = zeros(length(s1),2,6);
ac_iters   = zeros(length(s1),2);
p_err      = zeros(length(s1),2);
rej        = zeros(length(s1),2);
opt_global = zeros(length(s1),2);
opt_local  = zeros(length(s1),2);

for i=1:length(s1)
  sigmas(i,:) = [s1(i) s2(i)];
  
  for j=1:2
    ls_bars(i,j,:)  = mean(allstats{i}.rej.basics.ls{j}(:,[3:4 1:2 5:6]), 1);
    ac_iters(i,j)   = mean(allstats{i}.rej.ti.AC{j},1);
    p_err(i,j)      = mean(allstats{i}.rej.err.P{j},1);
    rej(i,j)        = length(find(sum(allstats{i}.raw.r{j},2)));
    opt_global(i,j) = mean(allstats{i}.rej.opt.train.global{j});
    opt_local(i,j)  = mean(allstats{i}.rej.opt.train.local{j});
  end;
end;

% Data extracted; now output
[j,sort_idx] = sort(sigmas(:));
ls_bars2 = reshape(ls_bars,length(s1)*2,6);

for i=1:length(sort_idx)
  idx = sort_idx(i);

  fprintf('%4.1f',    sigmas(idx));
  fprintf(' & %5.4f', ls_bars2(idx,:));
  fprintf(' & %4.3f & %4.3f', opt_global(idx), opt_local(idx));
  fprintf(' & %3d',   rej(idx));
  fprintf(' & %4.1f',   ac_iters(idx));
  fprintf(' & %5.4f', p_err(idx)/16);
  fprintf(' \\\\\n');
end;

corrs      = zeros(11,2);
corrs2     = zeros(11,2);
good_idx   = [1:9]';

[corrs(1,1),corrs(1,2)]   = corr(sigmas(:),ls_bars2(:,1));
[corrs(2,1),corrs(2,2)]   = corr(sigmas(:),ls_bars2(:,2));
[corrs(3,1),corrs(3,2)]   = corr(sigmas(:),ls_bars2(:,3));
[corrs(4,1),corrs(4,2)]   = corr(sigmas(:),ls_bars2(:,4));
[corrs(5,1),corrs(5,2)]   = corr(sigmas(:),ls_bars2(:,5));
[corrs(6,1),corrs(6,2)]   = corr(sigmas(:),ls_bars2(:,6));
[corrs(7,1),corrs(7,2)]   = corr(sigmas(:),opt_global(:));
[corrs(8,1),corrs(8,2)]   = corr(sigmas(:),opt_local(:));
[corrs(9,1),corrs(9,2)]   = corr(sigmas(:),rej(:));
[corrs(10,1),corrs(10,2)] = corr(sigmas(:),ac_iters(:));
[corrs(11,1),corrs(11,2)] = corr(sigmas(:),p_err(:)/16);

[corrs2(1,1),corrs2(1,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,1));
[corrs2(2,1),corrs2(2,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,2));
[corrs2(3,1),corrs2(3,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,3));
[corrs2(4,1),corrs2(4,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,4));
[corrs2(5,1),corrs2(5,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,5));
[corrs2(6,1),corrs2(6,2)]   = corr(sigmas(good_idx),ls_bars2(good_idx,6));
[corrs2(7,1),corrs2(7,2)]   = corr(sigmas(good_idx),opt_global(good_idx));
[corrs2(8,1),corrs2(8,2)]   = corr(sigmas(good_idx),opt_local(good_idx));
[corrs2(9,1),corrs2(9,2)]   = corr(sigmas(good_idx),rej(good_idx));
[corrs2(10,1),corrs2(10,2)] = corr(sigmas(good_idx),ac_iters(good_idx));
[corrs2(11,1),corrs2(11,2)] = corr(sigmas(good_idx),p_err(good_idx)/16);

% One line that shows correlations
fprintf('corr');
for i=1:size(corrs)
  if (corrs(i,2) < 0.05)
    chr = '*';
  else
    chr = ' ';
  end;
  
  fprintf(' & %4.3f%s', corrs(i,1), chr);
end;
fprintf('\\\\\n');

% One line that shows correlations
fprintf('corr');
for i=1:size(corrs2)
  if (corrs2(i,2) < 0.05)
    chr = '*';
  else
    chr = ' ';
  end;
  
  fprintf(' & %4.3f%s', corrs2(i,1), chr);
end;
fprintf('\\\\\n');
