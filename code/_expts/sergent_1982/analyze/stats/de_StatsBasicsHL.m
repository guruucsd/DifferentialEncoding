function stats = de_StatsBasicsHL(mSets, mss, verbose)
%
%

  % These stats are only meaningful if the classifier has been run.
  if (~isfield(mSets, 'p') || ~isfield(mSets.data.train, 'T')), stats = struct(); return; end;

  if (~exist('verbose','var')), verbose = false; end;

  [stats.ls,...
   stats.ls_mean,...
   stats.ls_stde, ...
   stats.ls_raw] = de_models2LS(mss, mSets.errorType);

  stats.bars      = horzcat(stats.ls_mean{:});
  stats.bars_stde = horzcat(stats.ls_stde{:});

  if (~verbose), return; end;


  % Run statisitcal tests and
  %   create a stats report,
  %

    % Log some results
  BARS = stats.bars

  % Log 'bars'
  fprintf('\t%s\n', sprintf('%3.1f\t', mSets.sigma(:)));
  for i=1:size(BARS,1)
    fprintf('\t%-10s:', mSets.data.aux.TLAB{i});
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
  if (length(stats.ls)~=2), return;
  elseif any(cellfun(@isempty,stats.ls)), return;
  end;


  ls = stats.ls([1 end]);
  ls_raw = stats.ls_raw([1 end]);

  if true

    % variable 'ls' is a cell array.  cells represent DE models
    % for each cell, there is a matrix;
    %   rows are model instances
    %   columns are position of target / stimulus condition (LpSm, etc)
    %   values in the matrix are the output error for the model instance for that condition.

    err_RH_L = [ls_raw{1}{:,mSets.data.aux.idx.LpSm}]';
    err_LH_L = [ls_raw{2}{:,mSets.data.aux.idx.LpSm}]';
    err_RH_S = [ls_raw{1}{:,mSets.data.aux.idx.LmSp}]';
    err_LH_S = [ls_raw{2}{:,mSets.data.aux.idx.LmSp}]';

    % Vector of all dependent measures: LpSm and LmSp data for LH and RH models
    Y   = [ err_RH_L; err_LH_L; ...
            err_RH_S; err_LH_S ];

    % Factor 1: Hemisphere
    F1  = [ repmat({'RH'},   [length(err_RH_L) 1]); repmat({'LH'},   [length(err_LH_L) 1]); ...
            repmat({'RH'},   [length(err_RH_S) 1]); repmat({'LH'},   [length(err_LH_S) 1]) ];

    % Factor 2: Target location
    F2  = [ repmat({'L+S-'}, [length(err_RH_L) 1]); repmat({'L+S-'}, [length(err_LH_L) 1]); ...
            repmat({'L-S+'}, [length(err_RH_S) 1]); repmat({'L-S+'}, [length(err_LH_S) 1]) ];

    ntrials = length(ls_raw{1}{end, mSets.data.aux.idx.LpSm}); % same for LmSp
    nmodels_RH = size(ls{1}, 1);
    nmodels_LH = size(ls{2}, 1);
    guru_assert(length(err_RH_L) / nmodels_RH == ntrials, 'Make sure about assumptions in stats dimensions.');

    % Factor 3: Target identity
    xlabs = mSets.data.train.XLAB(mSets.data.train.TIDX{mSets.data.aux.idx.LpSm});
    F3 = [repmat(xlabs, [nmodels_RH 1]); repmat(xlabs, [nmodels_LH 1]); ...
          repmat(xlabs, [nmodels_RH 1]); repmat(xlabs, [nmodels_LH 1]) ...
          ];


    model_indices_RH = ceil((0.5/ntrials):(1/ntrials):nmodels_RH);
    model_indices_LH = ceil((0.5/ntrials):(1/ntrials):nmodels_LH);

    % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
    S   = horzcat( guru_csprintf('RH%d', num2cell(model_indices_RH)), guru_csprintf('LH%d', num2cell(model_indices_LH)), ...
                   guru_csprintf('RH%d', num2cell(model_indices_RH)), guru_csprintf('LH%d', num2cell(model_indices_LH)) ...
                  )';

    % 3-way repeated measures anova,
    % Following instructions from
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/58226
    if false
        [~, stats.anova.stats] = anovan(Y, {F1 F2 F3 S}, 'random', 4, 'model', 'full', 'display', 'off', 'varnames', {'hemisphere', 'scale', 'stim', 'subject'}, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 1 0 0 0]);
        stats.anova.stats([1 2 3 4 5 6],[1 3 6 7 8])
    else
        [~, stats.anova.stats] = anovan(Y, {F1 F2 S}, 'random', 3, 'model', 'full', 'display', 'off', 'varnames', {'hemisphere', 'scale', 'subject'}, 'nested', [0 0 0; 0 0 0; 1 0 0]);
        stats.anova.stats(1:5,[1 3 6 7])
    end;

  else % cannot be elseif because some shared display code within this else is used.
    if false
        % variable 'ls' is a cell array.  cells represent DE models
        % for each cell, there is a matrix;
        %   rows are model instances
        %   columns are position of target / stimulus condition (LpSm, etc)
        %   values in the matrix are the output error for the model instance for that condition.

        err_RH_L = [ls_raw{1}{:,mSets.data.aux.idx.LpSm}]';
        err_LH_L = [ls_raw{2}{:,mSets.data.aux.idx.LpSm}]';
        err_RH_S = [ls_raw{1}{:,mSets.data.aux.idx.LmSp}]';
        err_LH_S = [ls_raw{2}{:,mSets.data.aux.idx.LmSp}]';

        % Vector of all dependent measures: LpSm and LmSp data for LH and RH models
        Y   = [ err_RH_L; err_LH_L; ...
                err_RH_S; err_LH_S ];

        % Factor 1: Hemisphere
        F1  = [ repmat({'RH'},   [length(err_RH_L) 1]); repmat({'LH'},   [length(err_LH_L) 1]); ...
                repmat({'RH'},   [length(err_RH_S) 1]); repmat({'LH'},   [length(err_LH_S) 1]) ];

        % Factor 2: Target location
        F2  = [ repmat({'L+S-'}, [length(err_RH_L) 1]); repmat({'L+S-'}, [length(err_LH_L) 1]); ...
                repmat({'L-S+'}, [length(err_RH_S) 1]); repmat({'L-S+'}, [length(err_LH_S) 1]) ];

        ntrials = length(ls_raw{1}{end, mSets.data.aux.idx.LpSm}); % same for LmSp
        nmodels_RH = size(ls{1}, 1);
        nmodels_LH = size(ls{2}, 1);
        model_indices_RH = ceil((0.5/ntrials):(1/ntrials):nmodels_RH);
        model_indices_LH = ceil((0.5/ntrials):(1/ntrials):nmodels_LH);

        % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
        S   = horzcat( guru_csprintf('RH%d', num2cell(model_indices_RH)), guru_csprintf('LH%d', num2cell(model_indices_LH)), ...
                       guru_csprintf('RH%d', num2cell(model_indices_RH)), guru_csprintf('LH%d', num2cell(model_indices_LH)) ...
                      )';

      else
        % variable 'ls' is a cell array.  cells represent DE models
        % for each cell, there is a matrix;
        %   rows are model instances
        %   columns are position of target / stimulus condition (LpSm, etc)
        %   values in the matrix are the output error for the model instance for that condition.

        % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
        S   = horzcat( guru_csprintf('RH%d', num2cell(1:size(ls{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(ls{2},1))), ...
                       guru_csprintf('RH%d', num2cell(1:size(ls{1},1))), ...
                       guru_csprintf('LH%d', num2cell(1:size(ls{2},1))) ...
                      )';

        % Vector of all dependent measures: LpSm and LmSp data for LH and RH models
        Y   = [ ls{1}(:,mSets.data.aux.idx.LpSm); ls{2}(:,mSets.data.aux.idx.LpSm); ...
                ls{1}(:,mSets.data.aux.idx.LmSp); ls{2}(:,mSets.data.aux.idx.LmSp) ];

        % Facor 1: Hemisphere
        F1  = [ repmat({'RH'},   [size(ls{1},1) 1]); repmat({'LH'},   [size(ls{2},1) 1]); ...
                repmat({'RH'},   [size(ls{1},1) 1]); repmat({'LH'},   [size(ls{2},1) 1]) ];

        % Factor 2: Target location
        F2  = [ repmat({'L+S-'}, [size(ls{1},1) 1]); repmat({'L+S-'}, [size(ls{2},1) 1]); ...
                repmat({'L-S+'}, [size(ls{1},1) 1]); repmat({'L-S+'}, [size(ls{2},1) 1]) ];
      end;

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
  end;