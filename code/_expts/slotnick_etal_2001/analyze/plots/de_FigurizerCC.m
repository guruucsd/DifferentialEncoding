%% Still needed:
% 1) Make the plots prettier.
% 2) Superimpose an error plot, or use mfe_barweb
% 3) Use a better method than try/catch to determine if cat vs coord
% 4) Implement code that generalizes based on the task (blob/dot vs paired
% squares etc)


function figs = de_FigurizerCC(mSets, mss, stats)

ds = 'test';

left = stats.rej.sf.perf.(ds){1};
right = stats.rej.sf.perf.(ds){2};

try % is this categorical? 
    
    left_results = left{1};
    right_results = right{1};
    
    left_average = mean(mean(left_results));
    right_average = mean(mean(right_results));
    
    left_stddev = std(left_results(:)');
    right_stddev = std(right_results(:)');
    fig = figure;
    bar([left_average right_average], 0.4);
    set(gca,'XTickLabel', {'LH', 'RH'});
    ylim([0 0.5]);
    title('Categorical Stimuli: Blob Dot'); 
    
   
    figs = [fig];
catch % must be coordinate
    
    left_results = left{2};
    right_results = right{2};
    
    left_average = mean(mean(left_results));
    right_average = mean(mean(right_results));
    
    left_stddev = std(left_results(:)');
    right_stddev = std(right_results(:)');
    
    fig = figure;
    bar([left_average right_average], 0.4);
    set(gca,'XTickLabel', {'LH', 'RH'});
    ylim([0 0.5]);
    title('Coordinate Stimuli: Blob Dot');
    figs = [fig];
end
