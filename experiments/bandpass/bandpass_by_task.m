scale=2; % if blob-dot, scale=2. else scale=1

imgsiz = [34, 25] * scale;
bandpass_width = 4;
bandpass_step = 1 * scale;

scriptname = 'slotnick_etal_2001/blob-dot/categorical';

low = 0;
high = low + bandpass_width;

ds = 'test';
center_freq = [];
results = [];
errors = [];
[args, opts]  = uber_slotnick_args('p.dropout', 0.7, 'sigma', [10, 10]);
orig_opts = opts;

while high <= max(imgsiz)/2
    opts = [orig_opts, 'bandpass', [low, high]];
    [trn, tst] = de_SimulatorUber('vanhateren/250', scriptname, opts, args);
    stats = tst.stats;
    left = stats.rej.cc.perf.(ds){end};
    runs = size(left{1});
    runs = runs(1);
    avg = mean(cellfun(@(d) mean(d(:)), left)); %For this script, assume sigmas are same
    results = [results, avg];
    center_freq = [center_freq, (low + high)/2];
    stddev = std2([left{1}, left{2}]);
    errors = [errors, stddev/sqrt(runs)];
    low = low + bandpass_step;
    high = high + bandpass_step;
    close all;

end

figure;
errorbar(center_freq, results, errors);
xlabel('Center Frequency (cycles/ img)');
ylabel('Sum Squared Error');
title(sprintf('SSE vs Frequency: Bandpass Step %d, Bandpass Width %d', ...
    bandpass_step, bandpass_width));
