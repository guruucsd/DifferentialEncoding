function stats = de_StaticizerOK(mSets, mss, dump)
if (~exist('dump','var')), dump = 0; end;

mss = {mss(1), mss(2)}; %hack to convert from struct array to cell array of structs

for ti=1:2
    if (ti==1), ds='train', else ds='test'; end;

    stats.perf.(ds) = cell(size(mss));

    for mi=1:length(mss)
        ms    = mss{mi};

        p     = [ms.p];
        o    = [p.output];

        tmp   = de_calcPErr( vertcat(o.(ds)), mSets.data.test.T, 2);
        if strcmp(ms.data.taskType, 'coordinate')
            trial_types = {'near', 'far'};
        else 
            trial_types = {'above', 'below'};
        end
        type1_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB, trial_types{1})); %2 freqs
        type2_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB, trial_types{2}));
        stats.perf.(ds){mi} = {type1_perf type2_perf};
    end;


    % Now do some reporting
    fprintf('\n');
    for mi=1:length(mss)
        fprintf('[%s] Sig=%5.2f:\t%s: %5.2e +/- %5.2e\t%s: %5.2e +/- %5.2e\n', ...
            ds, mss{mi}(1).sigma, ...
            trial_types{1}, ...
            mean(stats.perf.(ds){mi}{1}(:)), std(stats.perf.(ds){mi}{1}(:)), ...
            trial_types{2}, ...
            mean(stats.perf.(ds){mi}{2}(:)), std(stats.perf.(ds){mi}{2}(:)) ...
        );
    end;


    %%%%%%%%%%%%%%%%%%
    % Now test for significance
    %%%%%%%%%%%%%%%%%%

    % Can't do stats with a single sigma
    if (length(stats.perf.(ds)) < 2),  return; end;

    % Use the first and last sigmas as the two to compare
    perf = stats.perf.(ds)([1 end]);



    % First, test for main interaction of on/near vs. off/far

    % Vector of all dependent measures:
    % cell 1 is on/near responses, 2 is off/far; average over all instances of each stim class
    Y = [ mean(perf{1}{1},2); mean(perf{2}{1},2); ...
          mean(perf{1}{2},2); mean(perf{2}{2},2) ];

    % Subject names: "RH-and-model instance number" and "LH-and-model-instance-number"
    S = horzcat( guru_csprintf('RH%d', num2cell(1:size(perf{1}{1},1))), ...
        guru_csprintf('LH%d', num2cell(1:size(perf{2}{1},1))), ...
        guru_csprintf('RH%d', num2cell(1:size(perf{1}{2},1))), ...
        guru_csprintf('LH%d', num2cell(1:size(perf{2}{2},1))) ...
        )';

    % Factor 1: Hemisphere
    F1 = [ repmat({'RH'},   [size(perf{1}{1},1) 1]); repmat({'LH'},   [size(perf{2}{1},1) 1]); ...
         repmat({'RH'},   [size(perf{1}{2},1) 1]); repmat({'LH'},   [size(perf{2}{2},1) 1]) ];

    % Factor 2: On/off or Near/far
    F2 = [ repmat({trial_types{1}}, [size(perf{1}{1},1) 1]); repmat({trial_types{1}}, [size(perf{2}{1},1) 1]); ...
           repmat({trial_types{2}}, [size(perf{1}{2},1) 1]); repmat({trial_types{2}}, [size(perf{2}{2},1) 1]) ];

    % Convert all above labels to numeric
    [~,~,S_n] = unique(S);
    F1_n = zeros(size(F1)); F1_n(strcmp(F1,'RH')) = 1; F1_n(strcmp(F1,'LH')) = 2;
    F2_n = zeros(size(F2)); F2_n(strcmp(F2,trial_types{1})) = 1; F2_n(strcmp(F2,trial_types{2})) = 2;


    % Next, test for interaction between hemisphere and
    % Save off the info needed to run the stats
    stats.anova.(ds).Y   = Y;
    stats.anova.(ds).S_n = S_n;
    stats.anova.(ds).F1_n = F1_n;
    stats.anova.(ds).F2_n = F2_n;
    stats.anova.(ds).Fnames = {'hemi', 'trial type'};
    stats.anova.(ds).trial_types = trial_types;

    % repeated-measures anova:
    stats.anova.(ds).stats = mfe_anova_rm( stats.anova.(ds).Y, ...
        stats.anova.(ds).S_n, ...
        stats.anova.(ds).F1_n, ...
        stats.anova.(ds).F2_n, ...
        stats.anova.(ds).Fnames );

    % For the Slotnick tasks, we care to see if:
    %   If there is an interaction between the hemispheres and stimulus
    %   type, i.e. cat/coord (done in group analysis)
    %   To a lesser extent: if on/near and off/far interact with
    %   hemispheres (done here)

    stats.anova.(ds).stats([1 1+find(strcmp(stats.anova.(ds).Fnames,'trial type')) 4], :)




end

