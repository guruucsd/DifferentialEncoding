function fs=tdlc2013_figures(data_dir, plots, cache_file)

% paths
if ~exist('mfe_split','file'), addpath(genpath(fullfile(fileparts(mfilename), '..','..','code'))); end;

% Defaults & scrubbing input
if ~exist('data_dir', 'var'),  
    data_dir = fullfile(r_out_path('cache'), 'tdlc2013'); 
elseif ~exist(data_dir,'dir') && exist(fullfile(r_out_path('cache'), data_dir), 'dir')
    data_dir = fullfile(r_out_path('cache'), data_dir);
end;
if ~exist('plots','var'),      plots     = [ 0 ]; end;
if ~exist('cache_file', 'var'),cache_file= fullfile(r_out_path('cache'), 'tdlc2013_cache.mat'); end;

[data, nts, noise, delay] = collect_data_looped(data_dir, cache_file);
if    isempty(data),               error('No data found at %s', data_dir);
elseif ~exist(cache_file, 'file'), save_cache_data(cache_file); 
end;


ts = data{1}.ts;
ts.all = unique(nts);

%[allts,b,tsidx] = unique(nts);
%[alld, ~,didx]  = unique(delay);
%cidx = (noise==0);
%nidx = (noise==1);

fs = []; % output figure handles

%% Learning trajectory (raw)
if any(0<=plots & plots<1)
    % Raw learning
    lt_cdata = struct('intact', guru_getfield(data(noise==0 & delay==10), 'all.intact.clserr'), 'lesion', guru_getfield(data(noise==0 & delay==10), 'all.lesion.clserr'));
    lt_ndata = struct('intact', guru_getfield(data(noise==1 & delay==10), 'all.intact.clserr'), 'lesion', guru_getfield(data(noise==1 & delay==10), 'all.lesion.clserr'));
    if ismember(0, plots) || ismember(0.1, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce'); end;

    lt_cdata = struct('intact', guru_getfield(data(noise==0 & delay==10), 'all.intact.err'), 'lesion', guru_getfield(data(noise==0 & delay==10), 'all.lesion.err'));
    lt_ndata = struct('intact', guru_getfield(data(noise==1 & delay==10), 'all.intact.err'), 'lesion', guru_getfield(data(noise==1 & delay==10), 'all.lesion.err'));
    if ismember(0, plots) || ismember(0.2, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse'); end;
end;


    
function f0 = plot_pct_learning(cdata, ndata, ts, type)
    keyboard;
    

function f0 = plot_raw_learning(cdata, ndata, ts, type)
    
    % Plot a surface of training error (z) vs epoch (x), and how that
    % relates to time-step (y1)
    % 
    % Show clean only, d=10, lesion vs intact
    les_surf = zeros(length(ts.all), 10);
    int_surf = zeros(length(ts.all), 11);
    for tsi=1:length(cdata)
        les_surf(tsi,:) = mean(cdata(tsi).lesion, 1);
        int_surf(tsi,:) = mean(cdata(tsi).intact(:,ts.intact),1);
        %keyboard
    end;

    % Figure 0: Raw plots
    f0=figure('position', [37          33        1154         651]);
    subplot(2,2,1); caxis(get(gca,'zlim')); 
    set(gca, 'FontSize', 14);
    surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Intact (control (no noise))');
    
    subplot(2,2,2); caxis(get(gca,'zlim')); 
    set(gca, 'FontSize', 14);
    surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.lesion) max(ts.lesion)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Lesion (control (no noise))');
    
    
    % Figure 1 raw data, but on top of each other
    f1 = figure;
    subplot(1,2,1); set(gca, 'FontSize', 14);
    hold on; view(54.5,18); set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf); 
    surf(ts.lesion, ts.all, les_surf);
    xlabel('training epoch');     set(gca,'xlim', [min([ts.intact ts.lesion]) max([ts.intact ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Control (no noise))');
     
    
    % Figure 2: Lesion-induced error
    f2 = figure('position', [10         171        1262         325]);
    subplot(1,4,1);
    hold on; view(54.5,18);
    set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    dff = les_surf - int_surf(:,2:end);
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Lesion-induced error (control (no noise))');
    
    
    % Now re-do, for the noise plots
    les_surf = zeros(length(ts.all), 10);
    int_surf = zeros(length(ts.all), 11);
    for tsi=1:length(ndata)
        les_surf(tsi,:) = mean(ndata(tsi).lesion, 1);
        int_surf(tsi,:) = mean(ndata(tsi).intact(:,ts.intact),1);
    end;
        
    
    % Figure 0
    figure(f0);
    subplot(2,2,3);
    set(gca, 'FontSize', 14);
    surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]);  view(54.5,18);  caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Intact (expt (noise))');
    
    subplot(2,2,4); 
    set(gca, 'FontSize', 14);
    surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]); view(54.5,18); caxis(get(gca,'zlim'));
    xlabel('training epoch');     set(gca,'xlim', [min(ts.intact) max(ts.intact)]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Lesion (expt (noise))');
    
    
    % Figure 1
    figure(f1);
    subplot(1,4,2);
    hold on; view(54.5,18);  set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf);
    surf(ts.lesion, ts.all, les_surf);
    xlabel('training epoch');     set(gca,'xlim', [min([ts.intact ts.lesion]) max([ts.intact ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Expt (noise))');
    
    
    % Figure 2
    figure(f2);
    subplot(1,4,2); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Lesion-induced error (expt (noise))');
    
    % clean vs noise
    subplot(1,4,3); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, (dff - (les_surf - int_surf(:,2:end))));
    hold on; title('[clean lei] - [noise lei]')
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);

    % clean vs noise
    subplot(1,4,4); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, (dff - (les_surf - int_surf(:,2:end)))./((dff + (les_surf - int_surf(:,2:end)))/2));
    title('% ([clean lei] - [noise lei])')
    xlabel('training epoch');     set(gca,'xlim', [min([ts.lesion]) max([ts.lesion]) ]);
    ylabel('model time_{total}'); set(gca,'ylim', [min(ts.all) max(ts.all)]);
    hold on; title('Lesion-induced error (control (no noise))');
        
 