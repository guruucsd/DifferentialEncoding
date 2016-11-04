%
%
%

%
dbstop if warning;
dbstop if error;
addpath(genpath('../../code'));

outDir = fullfile(de_GetBaseDir(), 'results', 'crossover');

for sizeFactor=[2 3]
    sz = sizeFactor * [10 10];
    args = {
        'sz', sz, ...
        'Sigmas', [1:6 8 10], ...
        'cpi', [4:0.1:6], ...
        'nSamps', 10, ...
        'nBatches', 2, ...
    };

    rawFile = sprintf('data-%dx%d.mat', sz);
    if exist(rawFile, 'file'), continue; end;

    fprintf('Processing spatial frequency preferences for sz = [%d, %d]\n', sz);
    [avg_mean, std_mean, std_std, wts_mean, p] = sigma_vs_crossover( ...
        'disp', [11], ...
        args{:} ...
    );

    % Save results
    if ~exist(outDir, 'dir'), mkdir(outDir); end;
    for pltName = {'raw', 'crossovers'}
        pltName = pltName{1};
        outFile = fullfile(outDir, sprintf('plt-%s-%dx%d.png', pltName, sz));
        export_fig(gcf, outFile);
        close(gcf);
    end;
end;

