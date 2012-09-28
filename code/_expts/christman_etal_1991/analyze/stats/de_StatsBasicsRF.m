function stats = de_StatsBasicsRF(mSets, mss, dump)
  if (~exist('dump','var')), dump = 0; end;

for ti=1:2
  if (ti==1), ds='train', else ds='test'; end;
  %if (ti==2), keyboard; end;

  stats.perf.(ds) = cell(size(mss));

  for mi=1:length(mss)
      ms    = mss{mi};

      p     = [ms.p];
      o    = [p.output];

      tmp   = de_calcPErr( vertcat(o.(ds)), mSets.data.test.T, 2);
      %goodTrials = ~isnan(sum(mSets.data.(ds).T,1)); % only grab trials where

      S1_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'S1')); %2 freqs
      S2_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB,'S2')); %3 freqs

      stats.perf.(ds){mi} = {S1_perf S2_perf};
  end;


  % Now do some reporting
  fprintf('\n');
  for mi=1:length(mss)
      fprintf('[%s] Sig=%5.2f:\t2F: %5.2e +/- %5.2e\t3F: %5.2e +/- %5.2e\n', ds, mss{mi}(1).sigma, ...
              mean(stats.perf.(ds){mi}{1}(:)), std (stats.perf.(ds){mi}{1}(:)), ...
              mean(stats.perf.(ds){mi}{2}(:)), std (stats.perf.(ds){mi}{2}(:)) ...
              );
  end;



  %%%%%%%%%%%%%%%%%%
  % Now test for significance
  %%%%%%%%%%%%%%%%%%

  % Can't do stats with a single sigma
  if (length(stats.perf.(ds))<2),  return; end;

  % Choose two sigmas to compare
  if (length(stats.perf.(ds))==2)  % we only have 2; use them!
      perf = stats.perf.(ds);

  elseif (sum(mSets.sigma==3.0 | mSets.sigma==18.0)==2) %some tests I was doing for COSYNE 2012
      perf = stats.perf.(ds)(mSets.sigma==3.0 | mSets.sigma==18.0);

  else
      perf = stats.perf.(ds)([1 end]);
  end;

  % First, test for main interaction of S1=2Freqs vs S2=3Freqs

    % Vector of all dependent measures: cell 1 is S1 responses, 2 is S2; average over all instances of each stim class
    Y   = [ mean(perf{1}{1},2); mean(perf{2}{1},2); ...
            mean(perf{1}{2},2); mean(perf{2}{2},2) ];

    % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
    S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(perf{1}{1},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(perf{2}{1},1))), ...
                   guru_csprintf('RH%d', num2cell(1:size(perf{1}{2},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(perf{2}{2},1))) ...
                  )';

    % Facor 1: Hemisphere
    F1  = [ repmat({'RH'},   [size(perf{1}{1},1) 1]); repmat({'LH'},   [size(perf{2}{1},1) 1]); ...
            repmat({'RH'},   [size(perf{1}{2},1) 1]); repmat({'LH'},   [size(perf{2}{2},1) 1]) ];

    % Factor 2: Frequency
    F2  = [ repmat({'2F'}, [size(perf{1}{1},1) 1]); repmat({'2F'}, [size(perf{2}{1},1) 1]); ...
            repmat({'3F'}, [size(perf{1}{2},1) 1]); repmat({'3F'}, [size(perf{2}{2},1) 1]) ];

    % Convert all above labels to numeric
    [j1,j2,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH'))) = 1; F1_n(find(strcmp(F1,'LH'))) = 2;
    F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'2F'))) = 1; F2_n(find(strcmp(F2,'3F'))) = 2;


  % Next, test for interaction between hemisphere and
  % Save off the info needed to run the stats
  stats.anova.(ds).Y   = Y;
  stats.anova.(ds).S_n = S_n;
  stats.anova.(ds).F1_n = F1_n;
  stats.anova.(ds).F2_n = F2_n;
  stats.anova.(ds).Fnames = {'hemi', '# freqs'};

  % repeated-measures anova
  stats.anova.(ds).stats = mfe_anova_rm( stats.anova.(ds).Y, ...
									stats.anova.(ds).S_n, ...
									stats.anova.(ds).F1_n, ...
									stats.anova.(ds).F2_n, ...
									stats.anova.(ds).Fnames );

  % For the Christman task, we care to see if:
  %   2-component task is easier than 3-component task
  %   if there is an interaction between the hemispheres and stimulus type
  stats.anova.(ds).stats([1 1+find(strcmp(stats.anova.(ds).Fnames,'# freqs')) 4], :)
end