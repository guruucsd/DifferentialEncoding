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
        if (strcmp(mSets.data.taskType, 'categorical'))
            trial_types = {'on', 'off'};
        else
            trial_types = {'near', 'far'};
        end
        type1_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB, trial_types{1})); %2 freqs
        type2_perf = tmp(:, guru_instr(mSets.data.(ds).TLAB, trial_types{2}));
        stats.perf.(ds){mi} = {type1_perf type2_perf};
        
    end;
    
    
    % Now do some reporting
    fprintf('\n');
    for mi=1:length(mss)
        fprintf('[%s] Sig=%5.2f:\tOn: %5.2e +/- %5.2e\tOff: %5.2e +/- %5.2e\n', ds, mss{mi}(1).sigma, ...
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
    perf = stats.perf.(ds)([1 end]);
    
    
    
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
    
    
    
    % First, test for main interaction of on off
    
    % Factor 1: Hemisphere
    F1  = [ repmat({'RH'},   [size(perf{1}{1},1) 1]); repmat({'LH'},   [size(perf{2}{1},1) 1]); ...
        repmat({'RH'},   [size(perf{1}{2},1) 1]); repmat({'LH'},   [size(perf{2}{2},1) 1]) ];
    
    % Factor 2: On/off or Near/far
    F2  = [ repmat({trial_types{1}}, [size(perf{1}{1},1) 1]); repmat({trial_types{1}}, [size(perf{2}{1},1) 1]); ...
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
    
    % repeated-measures anova:
    % we h
    stats.anova.(ds).stats = mfe_anova_rm( stats.anova.(ds).Y, ...
        stats.anova.(ds).S_n, ...
        stats.anova.(ds).F1_n, ...
        stats.anova.(ds).F2_n, ...
        stats.anova.(ds).Fnames );
    
    % For the Christman task, we care to see if:
    %   2-component task is easier than 3-component task
    %   if there is an interaction between the hemispheres and stimulus type
    stats.anova.(ds).stats([1 1+find(strcmp(stats.anova.(ds).Fnames,'trial type')) 4], :)
    
    
    
    
end

