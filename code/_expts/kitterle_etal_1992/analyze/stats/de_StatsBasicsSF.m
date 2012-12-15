function stats = de_StatsBasicsSF(mSets, mss, dump)
  if (~exist('dump','var')), dump = 0; end;


  stats.perf = cell(size(mss));

  %
  for mi=1:length(mss)
      ms    = mss{mi}; 

      nMods = length(ms);                 % RH vs LH
      nFreq = length(mSets.data.freqs);  % freq1 vs freq2
      nWaves= 2;                         % sin vs square
      
      perf = zeros(nMods, nFreq, nWaves );
      p     = [ms.p];
      tmp   = de_calcPErr( vertcat(p.lastOutput), mSets.data.train.T, 2);

      for fi=1:nFreq
          freq_idx = guru_instr(mSets.data.train.XLAB,sprintf('freq=%3.2f',mSets.data.freqs(fi)));
          
          sin_perf = tmp(:,freq_idx & guru_instr(mSets.data.train.XLAB,'sin'));
          squ_perf = tmp(:,freq_idx & guru_instr(mSets.data.train.XLAB,'square'));
          
          perf(:, fi, 1) = mean(sin_perf,2);
          perf(:, fi, 2) = mean(squ_perf,2);
      end;
    stats.perf{mi} = perf;
  end;

  % Do some reporting
  fprintf('\n');
  for mi=1:length(mss)
  
      % Classify by frequency
      if (any(guru_instr(mSets.data.train.TLAB, 'freq')))
          f1d = stats.perf{mi}(:, 1, :);
          f2d = stats.perf{mi}(:, end, :);
          
          fprintf('Sigma: %5.2f:\tFr1: %5.2e +/- %5.2e\tFr2: %5.2e +/- %5.2e\tTot: %5.2e +/- %5.2e\n', mss{mi}(1).sigma, ...
          mean(f1d(:)), std(f1d(:)), ...
          mean(f2d(:)), std(f2d(:)), ...
          mean([f1d(:); f2d(:)]), std([f1d(:);f2d(:)]));

      % Classify by type
      elseif (any(guru_instr(mSets.data.train.TLAB, 'sin')))
          f1d = stats.perf{mi}(:, :, 1);
          f2d = stats.perf{mi}(:, :, end);
          
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
  if (length(stats.perf)<2),  return; end;

  % Choose two sigmas to compare  
  if (length(stats.perf)==2)  % we only have 2; use them! 
      perf = stats.perf;

  elseif (sum(mSets.sigma==3.0 | mSets.sigma==18.0)==2) %some tests I was doing for COSYNE 2012
      perf = stats.perf(mSets.sigma==3.0 | mSets.sigma==18.0);

  else
      perf = stats.perf([1 end]);
  end;   
  
  
    % variable 'ls' is a cell array.  cells represent DE models
    % for each cell, there is a matrix; 
    %   rows are model instances
    %   columns are position of target / stimulus condition (LpSm, etc)
    %   values in the matrix are the output error for the model instance for that condition.
    % Note: ONE value per model (averaged over all similar trials)
    
  if (any(guru_instr(mSets.data.train.TLAB, 'freq')))
  
    % Vector of all dependent measures: '1' and '2' are the frequencies
    Y   = [ mean(perf{1}(:,1,:),3); mean(perf{2}(:,2,:),3); ...
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

  elseif (any(guru_instr(mSets.data.train.TLAB, 'sin')))
  
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

  % repeated-measures anova
  mfe_anova_rm(Y, S_n, F1_n, F2_n, {'hemi', 'cond'})
 