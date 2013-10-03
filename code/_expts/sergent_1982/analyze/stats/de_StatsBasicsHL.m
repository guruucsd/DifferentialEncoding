function stats = de_StatsBasicsHL(mSets, mss, verbose)
%
%

  % These stats are only meaningful if the classifier has been run.
  if (~isfield(mSets, 'p') || ~isfield(mSets.data.train, 'T')), stats = struct(); return; end;

  if (~exist('verbose','var')), verbose = false; end;

  [stats.ls,...
   stats.ls_mean,...
   stats.ls_stde, ...
   stats.ls_pval] = de_models2LS(mss, mSets.errorType);

  stats.bars      = horzcat(stats.ls_mean{:});
  stats.bars_stde = horzcat(stats.ls_stde{:});
  stats.bars_pval = horzcat(stats.ls_pval{:});

  if (~verbose), return; end;


  % Run statisitcal tests and
  %   create a stats report,
  %

	% Log some results
  BARS = stats.bars

  % Log 'bars'
  fprintf('\t%s\n', sprintf('%3.1f\t', mSets.sigma(:)));
  for i=1:size(BARS,1)
    fprintf('\t%-10s:', mSets.data.aux.TLBL{i});
    for j=1:size(BARS,2)
      LS = stats.ls{j}(:,i);
      fprintf('\t%3.2e +/- %3.2e', mean(LS), std(LS));
    end;
    fprintf('\n');
  end;

  %%%%%%%%%%%%%%%%%%
  % Now test for significance
  %%%%%%%%%%%%%%%%%%

  % Can't do stats with a single sigma
  if (length(stats.ls)~=2),  return;
  elseif any(cellfun(@isempty,stats.ls)), return; end;

  
  ls = stats.ls([1 end]);

    % variable 'ls' is a cell array.  cells represent DE models
    % for each cell, there is a matrix;
    %   rows are model instances
    %   columns are position of target / stimulus condition (LpSm, etc)
    %   values in the matrix are the output error for the model instance for that condition.

    % Vector of all dependent measures: LpSm and LmSp data for LH and RH models
    Y   = [ ls{1}(:,mSets.data.aux.idx.LpSm); ls{2}(:,mSets.data.aux.idx.LpSm); ...
            ls{1}(:,mSets.data.aux.idx.LmSp); ls{2}(:,mSets.data.aux.idx.LmSp) ];

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
    [~,~,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(find(strcmp(F1,'RH')))   = 1; F1_n(find(strcmp(F1,'LH'))) = 2;
    F2_n = zeros(size(F2)); F2_n(find(strcmp(F2,'L+S-'))) = 1; F2_n(find(strcmp(F2,'L-S+'))) = 2;


  % Save off the info needed to run the stats
  stats.anova.Y   = Y;
  stats.anova.S_n = S_n;
  stats.anova.F1_n = F1_n;
  stats.anova.F2_n = F2_n;
  stats.anova.Fnames = {'hemi', 'scale'};

  % repeated-measures anova
  stats.anova.stats = mfe_anova_rm( stats.anova.Y, ...
									stats.anova.S_n, ...
									stats.anova.F1_n, ...
									stats.anova.F2_n, ...
									stats.anova.Fnames );

  % For the Sergent task, we care to see if:
  %   global level is easier than local level
  %   if there is an interaction between the hemispheres and level
  stats.anova.stats([1 1+find(strcmp(stats.anova.Fnames,'scale')) 4], :)


  % Dump for jmp
  %  fid = fopen('ben.tsv', 'w');
  %  fprintf(fid, '%s\t%s\t%s\t%s\n', 'value', 'subject', 'hemisphere', 'condition');
  %  for i=1:length(Y)
  %    fprintf(fid, '%f\t%s\t%s\t%s\n', Y(i), S{i}, F1{i}, F2{i});
  %  end;
  %  fclose(fid);
  %catch
  %end;
