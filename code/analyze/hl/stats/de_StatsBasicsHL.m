function stats = de_StatsBasicsHL(mSets, mss, dump)
%
%
  if (~exist('dump','var')), dump = 0; end;
  
  
  [stats.ls,...
   stats.ls_mean,...
   stats.ls_stde, ...
   stats.ls_pval] = de_models2LS(mss, mSets.errorType);

  stats.bars      = horzcat(stats.ls_mean{:});
  stats.bars_stde = horzcat(stats.ls_stde{:});
  stats.bars_pval = horzcat(stats.ls_pval{:});
  
  if (~dump), return; end;
  
  
  % Run statisitcal tests and 
  %   create a stats report,
  %   

	% Log some results
  BARS = stats.bars
  
  % Log 'bars'
  fprintf('\t%s\n', sprintf('%3.1f\t', mSets.sigma(:)));
  for i=1:size(BARS,1)
    fprintf('\t%-10s:', mSets.data.TLBL{i});
    for j=1:size(BARS,2)
      LS = stats.ls{j}(:,i);
      fprintf('\t%f +/- %f', mean(LS), guru_stde(LS));
    end;
    fprintf('\n');        
  end;
  
  % Log 'anova'
  % Now test for significance
  
  % Case 1: we have RH vs LH; use those as separate condiitons, compare
  
  if (length(stats.ls)==2)
  
    % variable 'ls' is a cell array.  cells represent DE models
    % for each cell, there is a matrix; 
    %   rows are model instances
    %   columns are position of target / stimulus condition (LpSm, etc)
    %   values in the matrix are the output error for the model instance for that condition.
    
    ls = stats.ls;
    stde = stats.ls_stde;
    
    % Vector of all dependent measures: LpSm and LmSp data for LH and RH models
    Y   = [ ls{1}(:,mSets.data.LpSm); ls{2}(:,mSets.data.LpSm); ...
            ls{1}(:,mSets.data.LmSp); ls{2}(:,mSets.data.LmSp) ];
            
    % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
    S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(ls{1},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(ls{2},1))), ...
                   guru_csprintf('RH%d', num2cell(1:size(ls{1},1))), ...
                   guru_csprintf('LH%d', num2cell(1:size(ls{2},1))) ...
                  )';
    
    % Facor 1: Hemisphere
    F1  = [ repmat({'RH'},   [size(ls{1},1) 1]); repmat({'LH'},   [size(ls{2},1) 1]); ...
            repmat({'RH'},   [size(ls{1},1) 1]); repmat({'LH'},   [size(ls{2},1) 1]) ];
            
    % Factor 2: Target location
    F2  = [ repmat({'L+S-'}, [size(ls{1},1) 1]); repmat({'L+S-'}, [size(ls{2},1) 1]); ...
            repmat({'L-S+'}, [size(ls{1},1) 1]); repmat({'L-S+'}, [size(ls{2},1) 1]) ];

    % Convert all above labels to numeric
    [j1,j2,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH')))   = 1; F1_n(find(strcmp(F1,'LH'))) = 2; 
    F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'L+S-'))) = 1; F2_n(find(strcmp(F2,'L-S+'))) = 2; 

    % repeated-measures anova
    mfe_anova_rm(Y, S_n, F1_n, F2_n, {'hemi', 'cond'})
  end;
  
  % Dump for jmp
  %  fid = fopen('ben.tsv', 'w');
  %  fprintf(fid, '%s\t%s\t%s\t%s\n', 'value', 'subject', 'hemisphere', 'condition');
  %  for i=1:length(Y)
  %    fprintf(fid, '%f\t%s\t%s\t%s\n', Y(i), S{i}, F1{i}, F2{i});
  %  end;
  %  fclose(fid);
  %catch
  %end;
