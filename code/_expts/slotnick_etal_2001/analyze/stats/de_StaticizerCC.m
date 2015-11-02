function stats = de_StaticizerCC(mSets, mss, dump)
  if (~exist('dump','var')), dump = 0; end;

for ti=1:2
  if (ti==1), ds='train', else ds='test'; end;

  stats.perf.(ds) = cell(size(mss));

  for mi=1:length(mss)
      ms    = mss{mi};

      p     = [ms.p];
      o    = [p.output];

      tmp   = de_calcPErr( vertcat(o.(ds)), mSets.data.test.T, 2);
      %goodTrials = ~isnan(sum(mSets.data.(ds).T,1)); % only grab trials where
      cat_on_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'on')); %2 freqs
      cat_off_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'off'));
      cat_perf = [cat_on_perf, cat_off_perf];
      
      coord_on_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'near')); %2 freqs
      coord_off_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'far'));
      coord_perf = [coord_on_perf, coord_off_perf];

      stats.perf.(ds){mi} = {cat_perf coord_perf};
  end;


  % Now do some reporting
  fprintf('\n');
  for mi=1:length(mss)
      fprintf('[%s] Sig=%5.2f:\t2F: %5.2e +/- %5.2e\t3F: %5.2e +/- %5.2e\n', ds, mss{mi}(1).sigma, ...
              mean(stats.perf.(ds){mi}{1}(:)), std (stats.perf.(ds){mi}{1}(:)), ...
              mean(stats.perf.(ds){mi}{2}(:)), std (stats.perf.(ds){mi}{2}(:)) ...
              );
  end;



end

