%close all;
clear all variables;
dbstop if error;

expt = 5;
size_facts  = [1 2 3]; % image size factors

% expt 1: shows same freq prefernces, but much larger differences for small images
% expt 2: as image size gets larger, shift freq preferences to high freqs
% expt 3: 
% expt 4: 
emu = @(sigma) (sigma*sqrt(2)/sqrt(pi));

% must square sigma to get mean distance from center equal
switch expt
    case {1, '1'}, sigma_facts = size_facts.^2; % as image size increases, so does sigma to compensate
    case {2, '2'}, sigma_facts = ones(size(size_facts));          % as image size increases, sigma does not change
    case {3, '3'}, sigma_facts = size_facts.^1; %as image size increases, sigma increases, but does not keep up (occurs in cortex)
    case {4, '4'}, sigma_facts = size_facts.^3; %as image size increases, sigma increases, but surpasses needed mean (does not occur)
    case {5, '5'}, sigma_facts = 1./size_facts;          % as image size increases, sigma does not change
end;

sigmas = sigma_facts'* [1.5 3 5 10 100];%[1/16 1/8 1/2 2 8]; %or sqrt(facts)+facts/2 => nonlinear that favors smaller facts (sigma relatively larger for smaller areas)
sizes  = size_facts' * [10 10];
cpi    = [.025 0.25 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 13 14 15]; % keep the same number of cycles per image 

nin    = [15 10 5];
nsamps = 25;

am = cell(length(sizes),1); sm=cell(size(am)); ss=cell(size(am)); wm=cell(size(am)); p=cell(size(am));

cl = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
colors = @(si,ci) (reshape(repmat(numel(sigmas(ci,:))-(si(:)-1), [1 3])/numel(sigmas(ci,:)) * 1 .* repmat(cl(ci,:),[numel(si) 1]),[numel(si) 3]));

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


lbls={}; lh1 = []; lh2=[];

for szi=1:length(sizes)
    
    [am{szi},sm{szi},ss{szi},wm{szi},p{szi}] = vary_sigma('sz', sizes(szi,:), 'Sigmas', sigmas(szi,:), 'distn', 'norme', ...
                                                          'nin', nin(szi),         'nsamps', nsamps, ...
                                                          'cpi', cpi,         'disp', [11 12]);
    % Re-label figure
    title(sprintf('non-normalized [%dx%d]', sizes(szi,:)));
    

   scaling = max(sm{szi}(:)); % make the scaling look close to 1
    
    
    % non-normalized
    figure(f1);

    for si=2:(length(sigmas(szi,:))-1)
      lht = plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/scaling, '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
      if si==2, lh1(szi) = lht; end;
    end;
    for si=2:(length(sigmas(szi,:))-1)
      errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:)/scaling, ss{szi}(si,:)/scaling, 'Color', colors(si,szi));
    end;
    
    lbls{szi} = sprintf('[%dx%dpx]', sizes(szi,:));
    legend(lh1, lbls, 'Location', 'best', 'FontSize',16);

%    set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);

    % non-normalized
    figure(f11);

    for si=2:(length(sigmas(szi,:))-1)
      plot(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:), '*-', 'Color', colors(si,szi), 'LineWidth', 3, 'MarkerSize', 5);
    end;
    for si=2:(length(sigmas(szi,:))-1)
      errorbar(p{szi}(1).cpi, sign(am{szi}(si,:)).*sm{szi}(si,:), ss{szi}(si,:), 'Color', colors(si,szi));
    end;
    
%    set(gca,'xlim', [min(cpi)-0.01 max(cpi)+0.01], 'ylim', [0 1.05]);


    % differences
    figure(f2);
    si=[1 size(sigmas,2)];
    lh2(szi) = plot(p{szi}(1).cpi, -diff(sm{szi}(si,:),1)/scaling, '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
    errorbar(p{szi}(1).cpi,        -diff(sm{szi}(si,:),1)/scaling, sum(ss{szi}(si,:),1)/scaling, 'Color', colors(1,szi));
    
    lbls{szi} = sprintf('[%dx%dpx]', sizes(szi,:));
    legend(lh2,lbls, 'Location', 'best', 'FontSize',16);

    % differences
    figure(f22);
    plot(p{szi}(1).cpi,       -diff(sm{szi}(si,:),1), '*-', 'Color', colors(1,szi), 'LineWidth', 3, 'MarkerSize', 5);
    errorbar(p{szi}(1).cpi,   -diff(sm{szi}(si,:),1), sum(ss{szi}(si,:),1), 'Color', colors(1,szi));
    
end;
