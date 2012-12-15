function stats = de_StatsBasicsSF(mSets, mss, verbose)
  if (~exist('verbose','var')), verbose = false; end;

  stats.perf = cell(size(mss));

  for mi=1:length(mss)
      ms    = mss{mi}; 
      p     = [ms.p];
      tmp   = de_calcPErr( vertcat(p.lastOutput), mSets.data.train.T, 2);
      
      % Classify via emotion
      if (guru_instr(mSets.data.train.TLAB, 'happy'))
          error('Analysis of classification by emotion is NYI');
          
      % Classify by individual
      else
         % Divide into classified as YES, and classified as NO, outputs
         o_yes = tmp(:,mSets.data.train.T==mSets.p.minmax(2));
         o_no  = tmp(:,mSets.data.train.T==mSets.p.minmax(1)); 
         stats.perf{mi} = {o_yes o_no};
      end;
  end;
  
  

  % Do some reporting
  fprintf('\n');
  for mi=1:length(mss)
       fprintf('Sig=%5.2f\tYes: %5.2e +/- %5.2e\tNo: %5.2e +/- %5.2e\n', mss{mi}(1).sigma, ...
             mean(stats.perf{mi}{1}(:)), std(stats.perf{mi}{1}(:)), ...
             mean(stats.perf{mi}{2}(:)), std(stats.perf{mi}{2}(:)) );
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
    
    % Vector of all dependent measures: cell 1 is 'yes' responses, 2 is 'no'; average over all faces
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
    F2  = [ repmat({'yes'}, [size(perf{1}{1},1) 1]); repmat({'yes'}, [size(perf{2}{1},1) 1]); ...
            repmat({'no' }, [size(perf{1}{1},1) 1]); repmat({'no' }, [size(perf{2}{1},1) 1]) ];

    % Convert all above labels to numeric
    [j1,j2,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH')))  = 1; F1_n(find(strcmp(F1,'LH'))) = 2; 
    F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'yes'))) = 1; F2_n(find(strcmp(F2,'no'))) = 2; 


  % repeated-measures anova
  mfe_anova_rm(Y, S_n, F1_n, F2_n, {'hemi', 'response(y/n)'})
