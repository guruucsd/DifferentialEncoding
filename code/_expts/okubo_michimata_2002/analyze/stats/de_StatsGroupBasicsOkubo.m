function stats = de_StatsGroupBasicsOkubo( all_models, all_mSets )

% 4 tasks, 2 hemis

n_expts = length(all_models);
n_hemis = size(all_models{1}, 2);

raw_sse = cell(n_expts, n_hemis);
n_models = zeros(n_expts, n_hemis);
median_sse = zeros(n_expts, n_hemis);
mean_sse = zeros(n_expts, n_hemis);
std_sse = zeros(n_expts, n_hemis);
stderr_sse = zeros(n_expts, n_hemis);

for ei=1:n_expts
    for hi=1:n_hemis  % RH=1, LH=2
        mSets = all_mSets{ei};
        o = arrayfun(@(mss) mss.p.output, all_models{ei}(hi));
        o_p       = reshape(vertcat(o.test),[numel(o(1).test),numel(o)])';  % # models x # trials

        raw_sse{ei, hi} = de_calcPErr( o_p, mSets.data.test.T, mSets.errorType );  % # models x # trials
        n_models(ei, hi) = size(raw_sse{ei, hi}, 1);
        median_sse(ei, hi) = median(raw_sse{ei, hi}(:));
        mean_sse(ei, hi) = mean(raw_sse{ei, hi}(:));
        std_sse(ei, hi) = std(raw_sse{ei, hi}(:));
        stderr_sse(ei, hi) = std_sse(ei, hi) / sqrt(n_models(ei, hi));
    end;
end;

stats = struct('raw_sse', {raw_sse}, ...
               'n_models', {n_models}, ...
               'median_sse', {median_sse}, ...
               'mean_sse', {mean_sse}, ...
               'std_sse', {std_sse}, ...
               'stderr_sse', {stderr_sse});
