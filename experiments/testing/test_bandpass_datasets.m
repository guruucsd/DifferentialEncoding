experiment_name = 'slotnick_etal_2001';
stimulus_type = 'paired-squares';
task_type = 'coordinate';
imgsiz = [34, 25];
maxfreq = max(imgsiz)/2;
bandpass_width = 4;
bandpass_step = 1;
numsteps = floor((maxfreq - bandpass_width)/bandpass_step) + 1;
low = 0; high = low+4;
scale = 4;
for ii=1:scale:numsteps
    de_MakeDataset(experiment_name, stimulus_type, task_type, {'small', 'bandpass', [low, high]}, true, true);
    
    set(gcf,'NextPlot','add');
    axes;
    h = title(sprintf('Bandpass [%d %d]', low, high));
    set(gca,'Visible','off');
    set(h,'Visible','on');

    low = low + scale;
    high = high + scale;
end
