%close all;
clear all variables;
dbstop if error;

% Amir et al (1993) results
amir.areas={'V1','V2','V4','7a'};
amir.patch_area = [.068 .075 .1 .131]; % mm^2
amir.patch_width = [0.23 0.25 0.27 0.31]; % mm "short axis"--diameter
amir.patch_nn = [0.61 1.15 1.39 1.56];    % mm
amir.avg_dist = [0.65 1.32 1.78 2.21];    % mm (from injection site)
amir.avg_dist_pct = [2.0 3.8 7.7 20.6];

amir.calc.patch_length = 2*amir.patch_area/pi./(amir.patch_width/2);%assume ellipse; Area = Pi * A * B where A&B are radii,
amir.calc.area_diameter = amir.avg_dist./(amir.avg_dist_pct./100); % estimated diameter /extent of cortical area
amir.calc.patch_nn_pct = amir.patch_nn./amir.calc.area_diameter*100;  %estimate of % area extent between nearest neighbors

min_sz = 55;%100./amir.calc.patch_nn_pct; % minimum image size to simulate that area

%%%%%%%
expt=1;

switch expt
    case {1, '1'}, 
        sz = [75 75];
        sigmas = [1 2 4 8 16 32 64 128];%
        cpi    = [.025 0.25 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 13 14 15]; % keep the same number of cycles per image 
        nin    = [1 1 1 1 1  1  1  1]*10;
        nsamps = 1;
end;

am = cell(size(sigmas)); sm=cell(size(am)); ss=cell(size(am)); wm=cell(size(am)); p=cell(size(am));

cl = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
colors = @(si,szi) (reshape(repmat(3-(si(:)-1), [1 3])/3 * 1 .* repmat(cl(szi,:),[numel(si) 1]),[numel(si) 3]));

% non-normalized
f1 = figure;
hold on;
set(gca, 'FontSize', 16);
xlabel('spatial frequency (cycles per image)');
ylabel('output activity (linear xfer fn)');
title('non-normalized (all)'); 

% non-normalized
f11 = figure;
hold on;
set(gca, 'FontSize', 16);
xlabel('spatial frequency (cycles per image)');
ylabel('output activity (linear xfer fn)');
title('non-normalized (all)'); 

f2 = figure;
hold on;
set(gca, 'FontSize', 16);
xlabel('spatial frequency (cycles per image)');
ylabel('output activity (linear xfer fn)');
title('differences (all)'); 

f22 = figure;
hold on;
set(gca, 'FontSize', 16);
xlabel('spatial frequency (cycles per image)');
ylabel('output activity (linear xfer fn)');
title('differences (all)'); 


lbls=cell(size(sigmas));
[r,c]=guru_optSubplots(length(sigmas));

for szi=1:length(sigmas)
    sigma_variations = sigmas(szi)*[.935 1 1.075]; %
    [am{szi},sm{szi},ss{szi},wm{szi},p{szi}] = vary_sigma('sz', sz,        'Sigmas', sigma_variations, 'distn', 'norme', ...
                                                          'nin', nin(szi), 'nsamps', nsamps, ...
                                                          'cpi', cpi,      'disp', [11 12]);
    % Re-label figure
    title(sprintf('non-normalized [%dx%d]', sz));
    

    scaling = max(sm{szi}(:)); % make the scaling look close to 1
    lbls{szi} = guru_csprintf('\\sigma=%.2f', num2cell(sigma_variations));
    
    
    % non-normalized
    figure(f1);
    subplot(r,c,szi);
    hold on;

    for si=1:length(sigma_variations)
      plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/scaling, '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
    end;
    for si=1:length(sigma_variations)
      errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/scaling, ss{szi}(si,:)/scaling, 'Color', colors(si,szi));
    end;
    
    %legend(lbls{szi}, 'Location', 'best', 'FontSize',16);

%    set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);

    % non-normalized
    figure(f11);
    subplot(r,c,szi);
    hold on;

    for si=1:length(sigma_variations)
      plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:), '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
    end;
    for si=1:length(sigma_variations)
      errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:), ss{szi}(si,:), 'Color', colors(si,szi));
    end;
    
    %legend(lbls{szi}, 'Location', 'best', 'FontSize',16);
%    set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);


    % differences
    figure(f2);

    si=[1 length(sigma_variations)];
    plot(p{szi}(1).cpi, -diff(sm{szi}(si,:),1)/scaling, '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
    errorbar(p{szi}(1).cpi,        -diff(sm{szi}(si,:),1)/scaling, sum(ss{szi}(si,:),1)/scaling, 'Color', colors(1,szi));
    
    legend({lbls{szi}{2}}, 'Location', 'best', 'FontSize',16);

    % differences
    figure(f22);
    plot(p{szi}(1).cpi,       -diff(sm{szi}(si,:),1), '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
    errorbar(p{szi}(1).cpi,   -diff(sm{szi}(si,:),1), sum(ss{szi}(si,:),1), 'Color', colors(1,szi));
    
    keyboard
end;

guru_saveall_figures(mfilename());

    
