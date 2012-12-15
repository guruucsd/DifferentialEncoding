function stats = de_StatsBasicsRF(mSets, mss, dump)
  if (~exist('dump','var')), dump = 0; end;


  stats.perf = cell(size(mss));
  
  %
  for mi=1:length(mss)
      ms    = mss{mi}; 

      p     = [ms.p];
      tmp   = de_calcPErr( vertcat(p.lastOutput), mSets.data.test.T, 2);
      goodTrials = ~isnan(sum(mSets.data.test.T,1));
      
      S1_perf = tmp(:, guru_instr(mSets.data.test.TLAB(goodTrials),'S1'));
      S2_perf = tmp(:, guru_instr(mSets.data.test.TLAB(goodTrials),'S2'));
      
      stats.perf{mi} = {S1_perf S2_perf};
  end;


  % Now do some reporting  
  fprintf('\n');
  for mi=1:length(mss)
      fprintf('Sig=%5.2f:\tS1: %5.2e +/- %5.2e\tS2: %5.2e +/- %5.2e\n', mss{mi}(1).sigma, ...
              mean(stats.perf{mi}{1}(:)), std (stats.perf{mi}{1}(:)), ...
              mean(stats.perf{mi}{2}(:)), std (stats.perf{mi}{2}(:)) ...
              );
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
  
  % First, test for main interaction of S1 vs S2
    
    % Vector of all dependent measures: cell 1 is S1 responses, 2 is S2; average over all instances of each stim class
    Y   = [ mean(perf{1}{1},2); mean(perf{2}{1},2); ...
            mean(perf{1}{2},2); mean(perf{2}{2},2) ];
            
    % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
    S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(perf{1}{1},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(perf{2}{1},1))), ...
                   guru_csprintf('RH%d', num2cell(1:size(perf{1}{1},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(perf{2}{1},1))) ...
                  )';
    
    % Facor 1: Hemisphere
    F1  = [ repmat({'RH'},   [size(perf{1}{1},1) 1]); repmat({'LH'},   [size(perf{2}{1},1) 1]); ...
            repmat({'RH'},   [size(perf{1}{1},1) 1]); repmat({'LH'},   [size(perf{2}{1},1) 1]) ];
            
    % Factor 2: Frequency
    F2  = [ repmat({'S1'}, [size(perf{1}{1},1) 1]); repmat({'S1'}, [size(perf{2}{1},1) 1]); ...
            repmat({'S2'}, [size(perf{1}{1},1) 1]); repmat({'S2'}, [size(perf{2}{1},1) 1]) ];

    % Convert all above labels to numeric
    [j1,j2,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH'))) = 1; F1_n(find(strcmp(F1,'LH'))) = 2; 
    F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'S1'))) = 1; F2_n(find(strcmp(F2,'S2'))) = 2; 


  % repeated-measures anova
  mfe_anova_rm(Y, S_n, F1_n, F2_n, {'hemi', 'stimulus class'})
  
  % Next, test for interaction between hemisphere and 
