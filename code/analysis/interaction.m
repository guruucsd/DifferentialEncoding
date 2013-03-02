
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
