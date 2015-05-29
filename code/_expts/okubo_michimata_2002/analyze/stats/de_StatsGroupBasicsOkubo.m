function stats = de_StatsGroupBasicsOkubo( all_models, all_mSets )

% 4 tasks, 2 hemis

n_expts = length(all_models);
n_hemis = size(all_models{1}, 2);

%all_models = {tst1.models tst2.models tst3.models tst4.models};
%all_mSets = {tst1.mSets tst2.mSets tst3.mSets tst4.mSets};

raw_error = cell(n_expts, n_hemis);
mean_error = zeros(n_expts, n_hemis);
std_error = zeros(n_expts, n_hemis);

for ei=1:n_expts
    for hi=1:n_hemis  % RH=1, LH=2
        models = all_models{ei}(:, hi);
        mSets = all_mSets{ei};
        p         = [models.p];
        o         = [p.output];
        o_p       = reshape(horzcat(o.test),[numel(o(1).test),length(o)])';  % # models x # trials
        
        raw_error{ei, hi} = de_calcPErr( o_p, mSets.data.test.T, mSets.errorType );        % # models x # trials
        mean_error(ei, hi) = mean(raw_error{ei, hi}(:));
        std_error(ei, hi) = std(raw_error{ei, hi}(:));
    end;
end;

stats = struct('raw_error', {raw_error}, ...
               'mean_error', {mean_error}, ...
               'std_error', {std_error});