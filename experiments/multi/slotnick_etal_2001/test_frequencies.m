imgsiz = [34, 25];
bandpass_width = 4;
bandpass_step = 2;

low = 0;
high = low + bandpass_width;

ds = 'test';
center_freq = [];
results = [];

while high <= max(imgsiz)/2
    [trn, tst] = uber_slotnick_plusminus_categorical([low, high]);
    stats = tst.stats;
    mSets = tst.mSets;
    left = stats.rej.cc.perf.(ds){end};
    runs = mSets.runs;
    avg = mean(cellfun(@(d) mean(d(:)), left)); %For this script, assume sigmas are same
    results = [results, avg];
    center_freq = [center_freq, (low + high)/2];
    low = low + bandpass_step;
    high = high + bandpass_step;

        
end

close all;
figure;
scatter(center_freq, results);
xlabel('Center Frequency (cycles/ img)');
ylabel('Sum Squared Error');
title(sprintf('SSE vs Frequency: Bandpass Step %d, Bandpass Width %d', ... 
    bandpass_step, bandpass_width));
        