function stats = de_StatsBasicsKit(mSets, mss, dump)
  if (~exist('dump','var')), dump = 0; end;


  for xi=1:2
    if (xi==1), ds='train';
    else,       ds='test'; end;

      stats.perf.(ds) = cell(size(mss));

	  %
	  for mi=1:length(mss)
		  ms    = mss{mi};

		  nMods = length(ms);                 % RH vs LH
		  nFreq = length(mSets.data.(ds).freqs);  % freq1 vs freq2
		  nWaves= 2;                         % sin vs square

		  perf = zeros(nMods, nFreq, nWaves );
		  p     = [ms.p];
		  o     = [p.output];
		  tmp   = de_calcPErr( vertcat(o.(ds)), mSets.data.(ds).T, mSets.p.errorType);

		  for fi=1:nFreq
			  freq_idx = guru_instr(mSets.data.(ds).XLAB,sprintf('freq=%3.2f',mSets.data.(ds).freqs(fi)));

			  sin_perf = tmp(:,freq_idx & guru_instr(mSets.data.(ds).XLAB,'sin'));
			  squ_perf = tmp(:,freq_idx & guru_instr(mSets.data.(ds).XLAB,'square'));

			  perf(:, fi, 1) = mean(sin_perf,2);
			  perf(:, fi, 2) = mean(squ_perf,2);
		  end;
		stats.perf.(ds){mi} = perf;
	  end;

	  % Do some reporting
	  fprintf('\n%s:\n',ds);
	  for mi=1:length(mss)

		  % Classify by frequency
		  if (any(guru_instr(mSets.data.(ds).TLAB, 'freq')))
			  f1d = stats.perf.(ds){mi}(:, 1, :);
			  f2d = stats.perf.(ds){mi}(:, end, :);

			  fprintf('Sigma: %5.2f:\tFr1: %5.2e +/- %5.2e\tFr2: %5.2e +/- %5.2e\tTot: %5.2e +/- %5.2e\n', mss{mi}(1).sigma, ...
			  mean(f1d(:)), std(f1d(:)), ...
			  mean(f2d(:)), std(f2d(:)), ...
			  mean([f1d(:); f2d(:)]), std([f1d(:);f2d(:)]));

		  % Classify by type
		  elseif (any(guru_instr(mSets.data.(ds).TLAB, 'sin')))
			  f1d = stats.perf.(ds){mi}(:, :, 1);
			  f2d = stats.perf.(ds){mi}(:, :, end);

			  fprintf('Sigma: %5.2f:\tsin: %5.2e +/- %5.2e\tsqu: %5.2e +/- %5.2e\tTot: %5.2e +/- %5.2e\n', mss{mi}(1).sigma, ...
			  mean(f1d(:)), std(f1d(:)), ...
			  mean(f2d(:)), std(f2d(:)), ...
			  mean([f1d(:); f2d(:)]), std([f1d(:);f2d(:)]));
		  end;
	  end;


      %%%%%%%%%%%%%%%%%%
      % Now test for significance
      %%%%%%%%%%%%%%%%%%

      % Can't do stats with a single sigma
      if (length(stats.perf.(ds))<2),  return; end;

      perf = stats.perf.(ds)([1 end]);


      % Compare based on frequency (low vs high)
      if (any(guru_instr(mSets.data.(ds).TLAB, 'freq')))
        cond_type = 'freq';

        % Vector of all dependent measures: '1' and '2' are the frequencies
        Y   = [ mean(perf{1}(:,1,:),3); mean(perf{2}(:,1,:),3); ...
                mean(perf{1}(:,2,:),3); mean(perf{2}(:,2,:),3) ];

        % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
        S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(perf{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(perf{2},1))), ...
                       guru_csprintf('RH%d', num2cell(1:size(perf{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(perf{2},1))) ...
                      )';

        % Facor 1: Hemisphere
        F1  = [ repmat({'RH'},   [size(perf{1},1) 1]); repmat({'LH'},   [size(perf{2},1) 1]); ...
                repmat({'RH'},   [size(perf{1},1) 1]); repmat({'LH'},   [size(perf{2},1) 1]) ];

        % Factor 2: Frequency
        F2  = [ repmat({'F1'}, [size(perf{1},1) 1]); repmat({'F1'}, [size(perf{2},1) 1]); ...
                repmat({'F2'}, [size(perf{1},1) 1]); repmat({'F2'}, [size(perf{2},1) 1]) ];

        % Convert all above labels to numeric
        [j1,j2,S_n] = unique(S);
        F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH'))) = 1; F1_n(find(strcmp(F1,'LH'))) = 2;
        F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'F1'))) = 1; F2_n(find(strcmp(F2,'F2'))) = 2;


      % Compare based on wave type
      elseif (any(guru_instr(mSets.data.(ds).TLAB, 'sin')))
        cond_type = 'type';

        % Vector of all dependent measures: '1' and '2' are the frequencies
        Y   = [ mean(perf{1}(:,:,1),2); mean(perf{2}(:,:,1),2); ...
                mean(perf{1}(:,:,2),2); mean(perf{2}(:,:,2),2) ];

        % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
        S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(perf{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(perf{2},1))), ...
                       guru_csprintf('RH%d', num2cell(1:size(perf{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(perf{2},1))) ...
                      )';

        % Facor 1: Hemisphere
        F1  = [ repmat({'RH'},   [size(perf{1},1) 1]); repmat({'LH'},   [size(perf{2},1) 1]); ...
                repmat({'RH'},   [size(perf{1},1) 1]); repmat({'LH'},   [size(perf{2},1) 1]) ];

        % Factor 2: Type of wave (sin vs square)
        F2  = [ repmat({'sin'}, [size(perf{1},1) 1]); repmat({'sin'}, [size(perf{2},1) 1]); ...
                repmat({'squ'}, [size(perf{1},1) 1]); repmat({'squ'}, [size(perf{2},1) 1]) ];

        % Convert all above labels to numeric
        [j1,j2,S_n] = unique(S);
        F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH'))) = 1;  F1_n(find(strcmp(F1,'LH'))) = 2;
        F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'sin'))) = 1; F2_n(find(strcmp(F2,'squ'))) = 2;

      end;

      % Save off the info needed to run the stats
      stats.anova.(ds).Y   = Y;
      stats.anova.(ds).S_n = S_n;
      stats.anova.(ds).F1_n = F1_n;
      stats.anova.(ds).F2_n = F2_n;
      stats.anova.(ds).Fnames = {'hemi', cond_type};

      % repeated-measures anova
      stats.anova.(ds).stats = mfe_anova_rm( stats.anova.(ds).Y, ...
                                            stats.anova.(ds).S_n, ...
                                            stats.anova.(ds).F1_n, ...
                                            stats.anova.(ds).F2_n, ...
                                            stats.anova.(ds).Fnames );

      % For the Kitterle task, what we really care is if
      %   the LH and RH differ for the task
      %   (i.e. main effect of hemisphere)
      stats.anova.(ds).stats([1 1+find(strcmp(stats.anova.(ds).Fnames,'hemi'))], :)
end;
