function fs=tdlc2013_figures(data_dir, plots, intype, etype, cache_file)
% intype: all, inter, intra
% etype : clserr, err (sse)
%

if ~exist('r_out_path',     'file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;
if ~exist('guru_getOptPath','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','..','_lib'))); end;

% default vars
if ~exist('plots','var'),  plots     = [ 0 1 ]; end;
if ~exist('intype','var'), intype = 'all'; end;
if ~exist('etype', 'var'), etype  = 'clserr'; end;
if ~exist('cache_file','var'), cache_file = ''; end;

% cache file with no dir data; set dir_data to empty
%   so that looper will know to load data from cache file
if strcmp('.mat', guru_fileparts(data_dir,'ext')) && isempty(cache_file)
    cache_file = data_dir;
    if ~exist(data_dir,'file'), error('Could not find cache file: %s', cache_file); end;
    data_dir = [];
    
% Fix path  
elseif ~exist(data_dir,'dir') && exist(fullfile(r_out_path('cache'), data_dir), 'dir')
    keyboard
    data_dir = fullfile(r_out_path('cache'), data_dir);
    
end;
    %if ~exist('cache_file', 'var'),cache_file= fullfile(r_out_path('cache'), 'tdlc2013_cache.mat'); end;

[data, nts, noise, delay] = collect_data_looped_tdlc(data_dir, cache_file);
if    isempty(data),               error('No data found at %s', data_dir);
elseif ~exist(cache_file, 'file'), save_cache_data(cache_file); end;
data = data(nts<75);
noise = noise(nts<75);
delay = delay(nts<75);
nts   = nts(nts<75);


ts = data{1}.ts;
ts.all = unique(nts);

%[allts,b,tsidx] = unique(nts);
%[alld, ~,didx]  = unique(delay);
%cidx = (noise==0);
%nidx = (noise==1);

fs = []; % output figure handles
udelays = unique(delay);
unoises = unique(noise);

%% Learning trajectory (raw)
if any(0<=plots & plots<1)
    for d=udelays
        lt_cdata = get_sub_data(data, noise==0 & delay==d, {[intype '.intact.' etype], [intype '.lesion.' etype]});
        lt_ndata = get_sub_data(data, noise==1 & delay==d, {[intype '.intact.' etype], [intype '.lesion.' etype]});

        % Raw learning; delay=d
        if ismember(0, plots) || ismember(0.0, plots), fs(end+1) = plot_raw_learning0(lt_cdata,lt_ndata,ts,sprintf('err=%s (delay=%d)',etype,d)); end;
        if ismember(0, plots) || ismember(0.1, plots), fs(end+1) = plot_raw_learning1(lt_cdata,lt_ndata,ts,sprintf('err=%s (delay=%d)',etype,d)); end;
        if ismember(0, plots) || ismember(0.2, plots), fs(end+1) = plot_raw_learning2(lt_cdata,lt_ndata,ts,sprintf('err=%s (delay=%d)',etype,d)); end;
    end;
end;

if any(1<=plots & plots<2)
    for n=unoises
        lt_nts       = nts(noise==n & delay==udelays(end));

        % Raw learning; delay=10 (classification error)
        lt_data_fast = get_sub_data(data, noise==n & delay==udelays(1),   {[intype '.intact.' etype], [intype '.lesion.' etype]});
        lt_data_slow = get_sub_data(data, noise==n & delay==udelays(end), {[intype '.intact.' etype], [intype '.lesion.' etype]});
        if ismember(1, plots) || ismember(1.1, plots), fs(end+1) = plot_ringo_curves1(lt_data_fast, lt_data_slow,ts,lt_nts,sprintf('err=%s (%s, noise=%d)',etype,intype,n)); end;
        if ismember(1, plots) || ismember(1.2, plots), fs(end+1) = plot_ringo_curves2(lt_data_fast, lt_data_slow,ts,lt_nts,sprintf('err=%s (%s, noise=%d)',etype,intype,n)); end;
    end;
end;

% 
% if any(2<=plots & plots<3)
%     for n=unoises
%         lt_nts       = nts(noise==n & delay==udelays(end));
% 
%         % Raw learning; delay=10 (classification error)
%         lt_data_fast = get_sub_data(data, noise==n & delay==udelays(1),   {[intype '.intact.' etype], [intype '.lesion.' etype]});
%         lt_data_slow = get_sub_data(data, noise==n & delay==udelays(end), {[intype '.intact.' etype], [intype '.lesion.' etype]});
%         if ismember(2, plots) || ismember(2.1, plots), fs(end+1) = plot_ringo_curves_normd(lt_data_fast, lt_data_slow,ts,lt_nts,sprintf('err=%s (%s, noise=%d)',etype,intype,n)); end;
%     end;
% end;


function [d] = get_sub_data(data, idx, propname)
  if ~iscell(propname), propname={propname}; end;
  
  args = cell(1, 2*numel(propname));
  
  for pi=1:length(propname)
      parts = mfe_split('.',propname{pi});
      args{2*pi-1} = parts{2};
      args{2*pi}   = guru_getfield(data(idx), propname{pi});

%      if isempty(vals{pi})
%          error('Couldn''t find property: %s', propname{pi});
%      end;
  end;

  d = struct(args{:});
  
  
function [les_mean,int_mean,les_std,int_std] = data2surf(data,ts)

    les_mean = zeros(length(ts.all), 10);
    int_mean = zeros(length(ts.all), 11);
    les_std  = zeros(length(ts.all), 10);
    int_std  = zeros(length(ts.all), 11);
    for tsi=1:length(data)
        les_mean(tsi,:) = mean(data(tsi).lesion, 1);
        int_mean(tsi,:) = mean(data(tsi).intact(:,ts.intact),1);
        les_std(tsi,:)  = std(data(tsi).lesion, [], 1);
        int_std(tsi,:)  = std(data(tsi).intact(:, ts.intact), [], 1);
    end;

function f0 = plot_raw_learning0(cdata, ndata, ts, type)
% Plot a surface of training error (z) vs epoch (x), and how that
% relates to time-step (y1)

    % Plot clean data first
    [les_surf,int_surf] = data2surf(cdata,ts);
    
    % Figure 0: Raw plots
    f0=figure('position', [37          33        1154         651]);
    subplot(2,2,1); caxis(get(gca,'zlim')); 
    set(gca, 'FontSize', 14);
    surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Intact (control (no noise); %s)',type));
    
    subplot(2,2,2); caxis(get(gca,'zlim')); 
    set(gca, 'FontSize', 14);
    surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.lesion) max(ts.lesion)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Lesion (control (no noise); %s)', type));
    
    % Now re-do, for the noise plots
    [les_surf,int_surf] = data2surf(ndata,ts);
    

    % Figure 0
    figure(f0);
    subplot(2,2,3);
    set(gca, 'FontSize', 14);
    surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]);  view(54.5,18);  caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Intact (expt (noise); %s)', type));
    
    subplot(2,2,4); 
    set(gca, 'FontSize', 14);
    surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Lesion (expt (noise); %s)', type));
    
        
function f1 = plot_raw_learning1(cdata, ndata, ts, type)
    % Plot clean data first
    [les_surf,int_surf] = data2surf(cdata,ts);
    
    % Figure 1 raw data, but on top of each other
    f1 = figure('Position', [57         245        1054         439]);
    subplot(1,2,1); set(gca, 'FontSize', 14);
    hold on; view(54.5,18); set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf); 
    surf(ts.lesion, ts.all, les_surf);
    xlabel('training epoch');     set(gca,'xlim', [min([ts.intact ts.lesion]) max([ts.intact ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Control (no noise); %s)', type));
     
    % Now re-do, for the noise plots
    [les_surf,int_surf] = data2surf(ndata,ts);
    

    % Figure 1
    figure(f1);
    subplot(1,2,2);
    set(gca, 'FontSize', 14);
    hold on; view(54.5,18);  set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf);
    surf(ts.lesion, ts.all, les_surf);
    xlabel('training epoch');     set(gca,'xlim', [min([ts.intact ts.lesion]) max([ts.intact ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Expt (noise); %s)', type));
    
    
    
function f2 = plot_raw_learning2(cdata, ndata, ts, type)

    % Plot clean data first
    [les_surf,int_surf] = data2surf(cdata,ts);
    
    % Figure 2: Lesion-induced error
    f2 = figure('position', [10         171        1262         325]);
    subplot(1,3,1);
    hold on; view(54.5,18);
    set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    dff = les_surf - int_surf(:,2:end);
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Lesion-induced error (control (no noise); %s)', type));
    
    
    % Now re-do, for the noise plots
    [les_surf,int_surf] = data2surf(ndata,ts);
    
    % Figure 2
    figure(f2);
    subplot(1,3,2); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title(sprintf('Lesion-induced error (expt (noise); %s)', type));
    
    % And now, diff
    subplot(1,3,3); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, (dff - (les_surf - int_surf(:,2:end))));
    hold on; title(sprintf('[clean lei] - [noise lei] (%s)', type));
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);

    
function fr = plot_ringo_curves1(data_fast, data_slow, ts,nts,type)
    [les_fastm,int_fastm,les_fasts,int_fasts] = data2surf(data_fast, ts);
    [les_slowm,int_slowm,les_slows,int_slows] = data2surf(data_slow, ts);
    
    lei_fastm = les_fastm(:,end)-int_fastm(:,end);
    lei_fasts = les_fasts(:,end)+int_fasts(:,end)/2;
    lei_slowm = les_slowm(:,end)-int_slowm(:,end);
    lei_slows = (les_slows(:,end)+int_slows(:,end))/2;

    fr = figure; set(gca, 'fontsize', 16);
    hold on;
    errorbar(nts, -lei_fastm, lei_fasts, '.k', 'LineWidth', 2);
    errorbar(nts,   -lei_slowm, lei_slows, '.k', 'LineWidth', 2);
    
    %
    plot(nts, int_fastm(:,end), 'b-');
    plot(nts, les_fastm(:,end), 'b--');
    plot(nts, int_slowm(:,end), 'r-');
    plot(nts, les_slowm(:,end), 'r--');
    
    %
    hf = plot(nts, -lei_fastm, 'v-b', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'LineWidth', 3);
         plot(nts+8, -lei_fastm, '--b', 'LineWidth', 2);
    hs = plot(nts, -lei_slowm, 'o-r', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    
    legend([hf hs], guru_csprintf(['%s ' type ')'], {'fast','slow'}), 'Location', 'NorthEast');
 

function fr = plot_ringo_curves2(data_fast, data_slow, ts,nts,type)

    % hack the type
    tdata = sscanf(type, 'err=%s (%5s, noise=%d');
    noise = tdata(end);
    errtype = char(tdata(1:end-6)');
    
    [les_fastm,int_fastm,les_fasts,int_fasts] = data2surf(data_fast, ts);
    [les_slowm,int_slowm,les_slows,int_slows] = data2surf(data_slow, ts);
    
    lei_fastm = les_fastm(:,end)-int_fastm(:,end);
    lei_fasts = les_fasts(:,end)+int_fasts(:,end)/2;
    lei_slowm = les_slowm(:,end)-int_slowm(:,end);
    lei_slows = (les_slows(:,end)+int_slows(:,end))/2;

    fr = figure('Position', [57   237   998   447]);
    
    subplot(1,2,1); set(gca, 'FontSize', 14);
    hf = plot(nts, -lei_fastm, 'v-b', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    hs = plot(nts, -lei_slowm, 'o-r', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 3);
    errorbar(nts, -lei_fastm, lei_fasts, '.k', 'LineWidth', 2);
    errorbar(nts,   -lei_slowm, lei_slows, '.k', 'LineWidth', 2);
    legend([hf hs], guru_csprintf(sprintf('%%s (noise=%d)', noise), {'D=2','D=10'}), 'Location', 'NorthEast');
    xlabel('timesteps'); ylabel(sprintf('\\Delta %s', errtype));
    title('Original', 'FontSize', 16);

    subplot(1,2,2); set(gca, 'FontSize', 14);
    hf = plot(nts+8, -lei_fastm, 'v-b', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    hs = plot(nts, -lei_slowm, 'o-r', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 3);
    errorbar(nts+8, -lei_fastm, lei_fasts, '.k', 'LineWidth', 2);
    errorbar(nts,   -lei_slowm, lei_slows, '.k', 'LineWidth', 2);
    set(gca, 'xlim', [10 
    xlabel('timesteps');
    title('Shifted', 'FontSize', 16);
        
function fr = plot_ringo_curves_normd(data_fast, data_slow, ts,nts,type)
    [les_fastm,int_fastm,les_fasts,int_fasts] = data2surf(data_fast, ts);
    [les_slowm,int_slowm,les_slows,int_slows] = data2surf(data_slow, ts);

%    lei_fastm = 1 - (les_fastm(:,end)-int_fastm(:,end))./(1-int_slowm(:,end));
%    lei_fasts = (les_fasts(:,end)+int_fasts(:,end))/2./(1-int_fastm(:,end));
%    lei_slowm = 1 - (les_slowm(:,end)-int_slowm(:,end))./(1-int_slowm(:,end));
%    lei_slows = (les_slows(:,end)+int_slows(:,end))/2./(1-int_slowm(:,end));

    lei_fastm = 1-(les_fastm(:,end)-int_fastm(:,end));
    lei_fasts = les_fasts(:,end)+int_fasts(:,end)/2/sqrt(10);
    lei_slowm = 1-(les_slowm(:,end)-int_slowm(:,end));
    lei_slows = (les_slows(:,end)+int_slows(:,end))/2/sqrt(10);

    fr = figure; set(gca, 'fontsize', 16);
    hold on;
    errorbar(nts, lei_fastm, lei_fasts, '.k', 'LineWidth', 2);
    errorbar(nts,   lei_slowm, lei_slows, '.k', 'LineWidth', 2);
    
    
    %
    hf = plot(nts, lei_fastm, 'v-b', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'LineWidth', 3);
    hfs= plot(nts+8,   lei_fastm, '--b', 'LineWidth', 2);
    hs = plot(nts,   lei_slowm, 'o-r', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    
    legend([hf hs], guru_csprintf(['%s ' type ')'], {'fast', 'fast (shifted)', 'slow'}), 'Location', 'NorthEast');
 
    
 
function fr = plot_ringo_curves_together(data_fast, data_slow, ts,nts,type)
    [les_fastm,int_fastm,les_fasts,int_fasts] = data2surf(data_fast, ts);
    [les_slowm,int_slowm,les_slows,int_slows] = data2surf(data_slow, ts);
    
    lei_fastm = les_fastm(:,end)-int_fastm(:,end);
    lei_fasts = les_fasts(:,end)+int_fasts(:,end);
    lei_slowm = les_slowm(:,end)-int_slowm(:,end);
    lei_slows = (les_slows(:,end)+int_slows(:,end))/2;

    fr = figure; set(gca, 'fontsize', 16);
    hold on;
    errorbar(nts, -lei_fastm, lei_fasts, '.k', 'LineWidth', 2);
    errorbar(nts, -lei_slowm, lei_slows, '.k', 'LineWidth', 2);
    
    %
    plot(nts, int_fastm(:,end), 'b-');
    plot(nts, les_fastm(:,end), 'b--');
    plot(nts, int_slowm(:,end), 'r-');
    plot(nts, les_slowm(:,end), 'r--');
    
    %
    hf = plot(nts, -lei_fastm, 'v-b', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'LineWidth', 3);
         plot(nts+8, -lei_fastm, '--b', 'LineWidth', 2);
    hs = plot(nts, -lei_slowm, 'o-r', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    
    legend([hf hs], guru_csprintf(['%s ' type ')'], {'fast','slow'}), 'Location', 'NorthEast');
 
    
 
