function tdlc2013_figures(data_dir, plots, force_load)

% paths
if ~exist('mfe_split','file'), addpath(genpath('~/GURU/de/code/lib/')); end;
% Defaults & scrubbing input
if ~exist('data_dir', 'var'),  data_dir = 'data/tdlc'; end;
if ~exist('plots','var'),      plots     = [ 0 ]; end;
if ~exist('force_load', 'var'),force_load= false; end;

[data, nts, noise, delay] = collect_data_looped(data_dir, force_load);
ts = data{1}.ts;
ts.all = unique(nts);

%[allts,b,tsidx] = unique(nts);
%[alld, ~,didx]  = unique(delay);
%cidx = (noise==0);
%nidx = (noise==1);

%% Learning trajectory (raw)
if any(0<=plots & plots<1)
    lt_cdata = struct('intact', guru_getfield(data(noise==0 & delay==10), 'all.intact.clserr'), 'lesion', guru_getfield(data(noise==0 & delay==10), 'all.lesion.clserr'));
    lt_ndata = struct('intact', guru_getfield(data(noise==1 & delay==10), 'all.intact.clserr'), 'lesion', guru_getfield(data(noise==1 & delay==10), 'all.lesion.clserr'));
    if ismember(0, plots) || ismember(0.1, plots), plot_raw_learning(lt_cdata,lt_ndata,ts,'bce'); end;

    lt_cdata = struct('intact', guru_getfield(data(noise==0 & delay==10), 'all.intact.err'), 'lesion', guru_getfield(data(noise==0 & delay==10), 'all.lesion.err'));
    lt_ndata = struct('intact', guru_getfield(data(noise==1 & delay==10), 'all.intact.err'), 'lesion', guru_getfield(data(noise==1 & delay==10), 'all.lesion.err'));
    if ismember(0, plots) || ismember(0.2, plots), plot_raw_learning(lt_cdata,lt_ndata,ts,'sse'); end;

    
end;


    
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
    
    f0=figure;
    subplot(2,2,1); caxis(get(gca,'zlim')); surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]); view(54.5,18);  caxis(get(gca,'zlim'));
    subplot(2,2,2); caxis(get(gca,'zlim')); surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]); view(54.5,18);  caxis(get(gca,'zlim'));
    
    
    f1 = figure;
    subplot(1,2,1);
    hold on; view(54.5,18); set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf); 
    surf(ts.lesion, ts.all, les_surf);
    
    f2 = figure;
    subplot(1,3,1);
    hold on; view(54.5,18);  title('clean lei');
    set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    dff = les_surf - int_surf(:,2:end);
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    
    
    
    les_surf = zeros(length(ts.all), 10);
    int_surf = zeros(length(ts.all), 11);
    for tsi=1:length(ndata)
        les_surf(tsi,:) = mean(ndata(tsi).lesion, 1);
        int_surf(tsi,:) = mean(ndata(tsi).intact(:,ts.intact),1);
    end;
        
    
    figure(f0);
    subplot(2,2,3);  surf(ts.intact, ts.all, int_surf); set(gca,'zlim', [0 0.8]);  view(54.5,18);  caxis(get(gca,'zlim'));
    subplot(2,2,4);  surf(ts.lesion, ts.all, les_surf); set(gca,'zlim', [0 0.8]);  view(54.5,18);  caxis(get(gca,'zlim'));

    figure(f1);
    subplot(1,2,2);
    hold on; view(54.5,18);  set(gca,'zlim', [0 0.8]);  caxis(get(gca,'zlim'));
    surf(ts.intact, ts.all, int_surf);
    surf(ts.lesion, ts.all, les_surf);
    
    
    figure(f2);
    subplot(1,3,2); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    title('noise lei')
    surf(ts.lesion, ts.all, les_surf - int_surf(:,2:end));
    
    % clean vs noise
    subplot(1,3,3); hold on; view(54.5,18);  set(gca,'zlim', [0 0.6]);  caxis(get(gca,'zlim'));
    surf(ts.lesion, ts.all, dff - (les_surf - int_surf(:,2:end)));
    title('[clean lei] - [noise lei]')

        
 