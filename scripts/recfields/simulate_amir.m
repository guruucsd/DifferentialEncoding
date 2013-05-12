function simulate_amir(expt, disp)

% Set variables
if ~exist('expt', 'var'), expt=1; end;
if ~exist('disp','var'), disp=[1 2 11 12]; end;
    
%% Choose the experimental parmaeters
switch expt
    case {1, '1'}, 
        sz = [35 35];
        sigmas = [1 2 4 8 16 32 64 128];%
        cpi    = [.025 0.25 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 13 14 15]; % keep the same number of cycles per image 
        nconns = ceil(2*linspace(5,25, length(sigmas))); %[1 1 1 1 1  1  1  1]*10;
        nsamps = 1;
    case {2, '2'}, 
        sz = [35 35];
        sigmas = [1 2 4 8 16 32 64 128];%
        cpi    = [.025 0.25 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 13 14 15]; % keep the same number of cycles per image 
        nconns = ceil(2*linspace(5,5, length(sigmas))); %[1 1 1 1 1  1  1  1]*10;
        nsamps = 2;
    otherwise, error('Unknown expt: %d', expt)
end;

% get paths
cur_dir = fileparts(which(mfilename));
matfile = fullfile(cur_dir, sprintf('%s-%d.mat', mfilename(), expt));

% Add paths
if ~exist('guru_csprintf','file'), addpath(genpath(fullfile(cur_dir, '../../../_lib'))); end;
if ~exist('de_calc_nn_dist','file'), addpath(genpath(fullfile(cur_dir, '../../code'))); end;


% Load a cached result
if exist(matfile, 'file')
    fprintf('Loading previous results from %s\n', matfile);
    load(matfile);
end;

%% Amir et al (1993) results
amir.areas={'V1','V2','V4','7a'};
amir.patch_area = [.068 .075 .1 .131]; % mm^2
amir.patch_width = [0.23 0.25 0.27 0.31]; % mm "short axis"--diameter
amir.patch_nn = [0.61 1.15 1.39 1.56];    % mm
amir.avg_dist = [0.65 1.32 1.78 2.21];    % mm (from injection site)
amir.avg_dist_pct = [2.0 3.8 7.7 20.6];

amir.calc.patch_length = 2*amir.patch_area/pi./(amir.patch_width/2);%assume ellipse; Area = Pi * A * B where A&B are radii,
amir.calc.area_diameter = amir.avg_dist./(amir.avg_dist_pct./100); % estimated diameter /extent of cortical area
amir.calc.patch_nn_pct = amir.patch_nn./amir.calc.area_diameter*100;  %estimate of % area extent between nearest neighbors

fact = 3; % how to convert from sigma to nearest_neighbor difference
amir.diff1 = [1.75 2.05];
amir.pct_diff = fact*(2*diff(amir.diff1)/mean(amir.diff1));
fprintf('Simulating %d with %5.2f%% difference.\n', nsamps, 100*amir.pct_diff)


% Only initialize if they haven't been computed previously.
if ~exist('am','var')
    am = cell(size(sigmas)); sm=cell(size(am)); ss=cell(size(am)); wm=cell(size(am)); p=cell(size(am));
end;

cl = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
cl = [cl; 0.5*cl];

colors = @(si,szi) (reshape(repmat(3-(si(:)-1), [1 3])/3 * 1 .* repmat(cl(szi,:),[numel(si) 1]),[numel(si) 3]));

if ismember(1, disp)
    f2 = figure;
    set(gcf, 'Position', [10          90        1266         594]);
    hold on;
    set(gca, 'xlim', [0 max(cpi)]);
    plot(get(gca, 'xlim'), [0 0], 'k--', 'LineWidth', 2.0);
    set(gca, 'FontSize', 16);
    xlabel('spatial frequency (cycles per image)');
    ylabel('output activity (linear xfer fn)');
    title('differences (all)'); 
end;

if ismember(11, disp)
    f22 = figure;
    set(gcf, 'Position', [10          90        1266         594]);
    hold on;
    set(gca, 'xlim', [0 max(cpi)]);
    plot(get(gca, 'xlim'), [0 0], 'k--', 'LineWidth', 2.0);
    set(gca, 'FontSize', 16);
    xlabel('spatial frequency (cycles per image)');
    ylabel('output activity (linear xfer fn)');
    title('differences (all)'); 
end;

%% Run the experiment
lbls=cell(length(sigmas),3);
[r,c]=guru_optSubplots(length(sigmas));

for szi=1:length(sigmas)
    sigma_variations = sigmas(szi)*[1-amir.pct_diff/2 1 1+amir.pct_diff/2]; %
    fprintf('Simulating on sigmas=[%s ]\n', sprintf(' %.2f', sigma_variations));
    
    % Avoid re-running if this was loaded from local cache
    if isempty(am{szi})
        % average_mean, std_mean, std_std, weights_mean, settings_object
        [am{szi},sm{szi},ss{szi},wm{szi},p{szi}] = vary_sigma('sz', sz,        'Sigmas', sigma_variations, 'distn', 'norme', ...
                                                              'nin', nconns(szi), 'nsamps', nsamps, ...
                                                              'cpi', cpi,      'disp', []);%11 12]);
    end;
    midpt = (length(sigma_variations)+1)/2;
    sdi=[1 length(sigma_variations)];


    scaling = max(sm{szi}(:)); % make the scaling look close to 1
    %lbls = cell(size(p));
    for si=1:length(sigma_variations)
        lbls{szi,si} = sprintf('d_{center}=%.1f%% (%.1fpx); d_{nn} = %.1f%% (%.1fpx)', ...
                             100*p{szi}(si).avg_dist/p{szi}(1).sz(1),      p{szi}(si).avg_dist, ...
                             100*mean(p{szi}(si).nn_dist/p{szi}(1).sz(1)), mean(p{szi}(si).nn_dist));
    end;
    dff = (mean(p{szi}(1).nn_dist)-mean(p{szi}(end).nn_dist))/((mean(p{szi}(1).nn_dist)+mean(p{szi}(end).nn_dist))/2);
    
    fprintf('\tActual difference: %5.2f%% difference.\n', dff)


    % non-normalized: scale to peak frequency (irrespective)
    if ismember(11, disp)
        sc = max(sm{szi}(:)); % overall scaling constant
        
        figure('Position', [360     6   768   672])
        hold on;
        h = [];
        for si=1:length(sigma_variations)
          if si==midpt
            h(end+1) = plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)./sc, ':', 'Color', colors(si,szi), 'LineWidth', 2);
          else
            h(end+1) = plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/sc, '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
            errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/sc, ss{szi}(si,:), 'Color', colors(si,szi));
          end;
        end;
        for si=1:length(sigma_variations)
          if si==midpt, continue; end;
        end;
        set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);
        set(gca, 'FontSize', 16);
        xlabel('frequency (cycles per image)');
        ylabel('output activity (linear xfer fn)');
        legend(h, lbls(szi,:), 'Location', 'NorthEast', 'FontSize',16);
        title('Semi-normalized std (divided by global max)');
    end;
    

    % Normalized
    if ismember(12, disp)
        figure('Position', [360     6   768   672])
        hold on;
        h = [];
        for si=1:length(sigma_variations)
          mx = max(sm{szi}(si,:)); % max for THIS sigma
          if si==midpt
            h(end+1) = plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)./mx, ':', 'Color', colors(si,szi), 'LineWidth', 2);
          else
            h(end+1) = plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)./mx, '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
            errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)./mx, ss{szi}(si,:), 'Color', colors(si,szi));
          end;
        end;
        set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01]);
        set(gca, 'FontSize', 16);
        xlabel('frequency (cycles per image)');
        ylabel('output activity (normalized)');
        legend(h, lbls(szi,:), 'Location', 'NorthEast', 'FontSize',14);
        title('Normalized std (each sigma''s response divided by its max)');    
    end;
    

    % differences
    if ismember(1, disp)
        sc = max(sm{szi}(:)); % overall scaling constant
        figure(f2);
        plot(p{szi}(1).cpi, -diff(sign(am{szi}(sdi,:)).*sm{szi}(sdi,:),1)./sc, '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
        legend(lbls(1:szi,midpt), 'Location', 'NorthEast', 'FontSize',16);
        title('semi-normalized (global max)')
    end;
    
    % differences
    if ismember(2, disp)
        mx = max(sm{szi}(sdi,:),[],2); % max for THIS sigma
        figure(f22);
        plot(p{szi}(1).cpi,       -diff(sm{szi}(sdi,:)./repmat(mx, [1 length(cpi)]),1), '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
        legend(lbls(1:szi,midpt), 'Location', 'NorthEast', 'FontSize',16);
        title('normalized (per-sigma max)')
    end;

    guru_saveall_figures(mfilename(), 'png', false);
end;

if ismember(1, disp)
    figure(f2);% = figure;
    plot(get(gca, 'xlim'), [0 0], 'k--', 'LineWidth', 2.0);
end;
if ismember(11, disp)
    figure(f22);% = figure;
    plot(get(gca, 'xlim'), [0 0], 'k--', 'LineWidth', 2.0);
end;

save(matfile);
guru_saveall_figures(mfilename(), 'fig');
guru_saveall_figures(mfilename(), 'png');
%guru_saveall_figures(mfilename(), 'eps');
close all;
