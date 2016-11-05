%
%
%

%
dbstop if warning;
dbstop if error;
addpath(genpath('../../code'));

outDir = fullfile(de_GetBaseDir(), 'results', 'crossover');
argsBySize = { ...
  { 'sz', [10, 10], 'nConns', 9,  'Sigmas', [1:4 10],   'cpi', [0:0.125:4] }, ...
  { 'sz', [20, 20], 'nConns', 20, 'Sigmas', [1 4:4:12], 'cpi', [0:0.25:6] }, ...
  { 'sz', [30, 30], 'nConns', 20, 'Sigmas', [1 4:4:12], 'cpi', [0:0.25:8] }, ...
  { 'sz', [34, 25], 'nConns', 20, 'Sigmas', [1 4:4:12], 'cpi', [0:0.25:8] } ...
};
for ai = 1:length(argsBySize)
    sz = argsBySize{ai}{2};  % hack...
    args = {
        argsBySize{ai}{:}, ...
        'nSamps', 10, ...
        'nBatches', 5, ...
        'seed', ai ...  % different seed per size
        'normInput', true ...  % doesn't much matter, esp. at larger image sizes
    };

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

