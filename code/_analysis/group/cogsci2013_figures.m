function fs = cogsci2013_figures(clean_dir, noise_dir, plots, cache_file)

% Defaults & scrubbing input
%if ~exist('clean_dir', 'var'), clean_dir = 'nonoise.10'; end;
%if ~exist('noise_dir', 'var'), noise_dir = 'noise.10.1'; end;
if ~exist('plots','var'),      plots     = [ 0.25 ]; end;
if ~exist('cache_file', 'var'),cache_file= fullfile(r_out_path('cache'),'cs2013_cache.mat'); end;

[cdata,ts] = get_cache_data(clean_dir, cache_file);
[ndata]    = get_cache_data(noise_dir, cache_file);


fs = []; % output figure handles

%% Learning trajectory (raw)
if any(0<=plots & plots<1)
    % All
    lt_cdata = struct('intact', cdata.all.intact.clserr, 'lesion', cdata.all.lesion.clserr);
    lt_ndata = struct('intact', ndata.all.intact.clserr, 'lesion', ndata.all.lesion.clserr);
    if ismember(0, plots) || ismember(0.1, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce'); end;
    if ismember(0, plots) || ismember(0.3, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); end; %overlay on single axes
    
    lt_cdata = struct('intact', cdata.all.intact.err, 'lesion', cdata.all.lesion.err);
    lt_ndata = struct('intact', ndata.all.intact.err, 'lesion', ndata.all.lesion.err);
    if ismember(0, plots) || ismember(0.2, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse'); end;
    if ismember(0, plots) || ismember(0.4, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); end;%overlay on single axes

    % Intra
    lt_cdata = struct('intact', cdata.intra.intact.clserr, 'lesion', cdata.intra.lesion.clserr);
    lt_ndata = struct('intact', ndata.intra.intact.clserr, 'lesion', ndata.intra.lesion.clserr);
    if ismember(0, plots) || ismember(0.5, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); title([get(get(gca,'Title'),'String') '(intra)']); end; %overlay on single axes
    
    lt_cdata = struct('intact', cdata.intra.intact.err, 'lesion', cdata.intra.lesion.err);
    lt_ndata = struct('intact', ndata.intra.intact.err, 'lesion', ndata.intra.lesion.err);
    if ismember(0, plots) || ismember(0.6, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); title([get(get(gca,'Title'),'String') '(intra)']); end; %overlay on single axes

    % Inter
    lt_cdata = struct('intact', cdata.inter.intact.clserr, 'lesion', cdata.inter.lesion.clserr);
    lt_ndata = struct('intact', ndata.inter.intact.clserr, 'lesion', ndata.inter.lesion.clserr);
    if ismember(0, plots) || ismember(0.7, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); title([get(get(gca,'Title'),'String') '(inter)']);  end; %overlay on single axes
    
    lt_cdata = struct('intact', cdata.inter.intact.err, 'lesion', cdata.inter.lesion.err);
    lt_ndata = struct('intact', ndata.inter.intact.err, 'lesion', ndata.inter.lesion.err);
    if ismember(0, plots) || ismember(0.8, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); title([get(get(gca,'Title'),'String') '(inter)']);  end; %overlay on single axes
    
    clear('lt_cdata', 'lt_ndata');
end;

%% Learning trajectory (diff)
if any(1<=plots & plots<2)
    % All
    lt_cdata = struct('mean', cdata.all.lei.clsmean, 'std', cdata.all.lei.clsstd);
    lt_ndata = struct('mean', ndata.all.lei.clsmean, 'std', ndata.all.lei.clsstd);
    if ismember(1, plots) || ismember(1.3, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce'); end;
    
    lt_cdata = struct('mean', cdata.all.lei.errmean, 'std', cdata.all.lei.errstd);
    lt_ndata = struct('mean', ndata.all.lei.errmean, 'std', ndata.all.lei.errstd);
    if ismember(1, plots) || ismember(1.4, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse'); end;

    % Intra
    lt_cdata = struct('mean', mean(cdata.intra.lei.cls,1), 'std', std(cdata.intra.lei.cls,[],1));
    lt_ndata = struct('mean', mean(ndata.intra.lei.cls,1), 'std', std(ndata.intra.lei.cls,[],1));
    if ismember(1, plots) || ismember(1.5, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce'); end;
    
    lt_cdata = struct('mean', mean(cdata.intra.lei.err,1), 'std', std(cdata.intra.lei.err,[],1));
    lt_ndata = struct('mean', mean(ndata.intra.lei.err,1), 'std', std(ndata.intra.lei.err,[],1));
    if ismember(1, plots) || ismember(1.6, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse'); end;

    % Inter
    lt_cdata = struct('mean', mean(cdata.inter.lei.cls,1), 'std', std(cdata.inter.lei.cls,[],1));
    lt_ndata = struct('mean', mean(ndata.inter.lei.cls,1), 'std', std(ndata.inter.lei.cls,[],1));
    if ismember(1, plots) || ismember(1.7, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce'); end;
    
    lt_cdata = struct('mean', mean(cdata.inter.lei.err,1), 'std', std(cdata.inter.lei.err,[],1));
    lt_ndata = struct('mean', mean(ndata.inter.lei.err,1), 'std', std(ndata.inter.lei.err,[],1));
    if ismember(1, plots) || ismember(1.8, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse'); end;

    clear('lt_cdata', 'lt_ndata');
end;


%% Raw plot of lesion induced errors
if any(2<=plots & plots<3)
    lei_cdata = struct('intra', cdata.intra.lei.cls, 'inter', cdata.inter.lei.cls);
    lei_ndata = struct('intra', ndata.intra.lei.cls, 'inter', ndata.inter.lei.cls);
    if ismember(2, plots) || ismember(2.1, plots), fs(end+1) = plot_lei_split(lei_cdata,lei_ndata,ts,'bce'); end;
    
    lei_cdata = struct('intra', cdata.intra.lei.err, 'inter', cdata.inter.lei.err);
    lei_ndata = struct('intra', ndata.intra.lei.err, 'inter', ndata.inter.lei.err);
    if ismember(2, plots) || ismember(2.2, plots), fs(end+1) = plot_lei_split(lei_cdata,lei_ndata,ts,'sse'); end;
end;
    

%% Similarity matrix
if any(3<=plots & plots<4)
    keyboard
    if ismember(3, plots) || ismember(3.1, plots), fs(end+1) = plot_hu_sim(cdata.all,ndata.all); end;
    if ismember(3, plots) || ismember(3.2, plots), fs(end+1) = plot_hu_sim(cdata.intra,ndata.intra); end;
    if ismember(3, plots) || ismember(3.3, plots), fs(end+1) = plot_hu_sim(cdata.inter,ndata.inter); end;
end;


%% Distribution of fibers
if any(4<=plots & plots<5)
    keyboard
end;



function f = plot_hu_sim(cdata, ndata)
%
%
    f = figure;
    
    subplot(2,2,1);
    imagesc(cdata.intact.rh_sim);
    set(gca, 'xtick',[],'ytick',[]);
    title('(no-noise) RH Similarity (intact)');

    subplot(2,2,2);
    imagesc(cdata.lesion.rh_sim);
    set(gca, 'xtick',[],'ytick',[]);
    title('(no-noise) RH Similarity (lesion)');

    subplot(2,2,3);
    imagesc(ndata.intact.lh_sim);
    set(gca, 'xtick',[],'ytick',[]);
    title('(noise) LH Similarity (intact)');
    
    subplot(2,2,4);
    imagesc(ndata.lesion.lh_sim);
    set(gca, 'xtick',[],'ytick',[]);
    xlabel('LH pattern #');
    title('(noise) LH Similarity (lesion)');

    
    
function f = plot_lei_split(cdata,ndata,ts,dtype)
%

    f = figure;
    ddlbls = datatype_dependent_labels(dtype);

    % No noise first
    cc = ddlbls.colors{1};
    nc = ddlbls.colors{2}; 
    ram = ddlbls.markers{1}; % intra-hemispheric
    erm = ddlbls.markers{2}; %inter-hemispheric

    subplot(1,2,1);
    hold on;
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error');
    xlabel('training epoch'); ylabel(['\Delta ' ddlbls.ylbl]);
    lh1=plot(ts.lesion,      mean(cdata.intra,1), [cc ram '-.'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh2=plot(ts.lesion,      mean(ndata.intra,1), [nc ram '-.'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    lh3=plot(ts.lesion,      mean(cdata.inter,1), [cc erm '-.'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh4=plot(ts.lesion,      mean(ndata.inter,1), [nc erm '-.'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.lesion,  mean(cdata.intra,1), std(cdata.intra,[],1), [cc '.']);
    errorbar(ts.lesion,  mean(ndata.intra,1), std(ndata.intra,[],1), [nc '.']);
    errorbar(ts.lesion,  mean(cdata.inter,1), std(cdata.inter,[],1), [cc '.']);
    errorbar(ts.lesion,  mean(ndata.inter,1), std(ndata.inter,[],1), [nc '.']);
    legend([lh1 lh2 lh3 lh4], {'Intra- (control)', 'Intra- (noise)', 'Inter- (control)', 'Inter- (noise)'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick([1 end-1]));
    set(gca, 'ytick', ddlbls.ytick(1:end-1), 'yticklabel', ddlbls.yticklabel(1:end-1));


    intra_dd_mean = mean(cdata.intra,1) - mean(ndata.intra,1);
    inter_dd_mean = mean(cdata.inter,1) - mean(ndata.inter,1);
    intra_dd_std  = std(cdata.intra,[],1) + std(ndata.intra,[],1);
    inter_dd_std  = std(cdata.inter,[],1) + std(ndata.inter,[],1);
    
    subplot(1,2,2);
    hold on;
    set(gca, 'FontSize', 18);
    title('b) \Delta Lesion-induced error');
    xlabel('training epoch'); ylabel(['\Delta \Delta ' ddlbls.ylbl]);
    lh1=plot(ts.lesion, intra_dd_mean, [ram 'k-.'], 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    lh2=plot(ts.lesion, inter_dd_mean, [erm 'k-.'], 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion, intra_dd_mean, intra_dd_std, 'k.');
    errorbar(ts.lesion, inter_dd_mean, inter_dd_std, 'k.');
    legend([lh1 lh2], {'Intrahemispheric patterns', 'Interhemispheric patterns', }, 'FontSize', 16);
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick(floor(end/2)).*[-1 1]);
%    set(gca, 'ytick', ddlbls.ytick().*[-1 1], 'yticklabel', {['-' ddlbls.yticklabel{floor(end/2)}] ddlbls.yticklabel{floor(end/2)}});
    axis square;


    drawnow;
    set(gcf, 'Position', [10          90        1266         594]);


% Dependence across delays


%% Raw plot of lesion induced errors
function f = plot_raw_lei(cdata,ndata,ts,dtype)
%
    f = figure;
    ddlbls = datatype_dependent_labels(dtype);

    % No noise first
    cc = ddlbls.colors{1};
    nc = ddlbls.colors{2};
    hold on;
    set(gca, 'FontSize', 18);
    title('Lesion-induced error (Error_{lesion}-Error_{intact})');
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    plot(ts.lesion,      cdata.mean, [cc '.-'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    plot(ts.lesion,      ndata.mean, [nc '.-'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.lesion,  cdata.mean, cdata.std/2, [cc '.']);
    errorbar(ts.lesion,  ndata.mean, ndata.std/2, [nc '.']);
    legend({'Control', 'Noise'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick([1 end-1]));
    set(gca, 'ytick', ddlbls.ytick(1:end-1), 'yticklabel', ddlbls.yticklabel(1:end-1));
    %set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);%[0.1 0.8]);
    %set(gca, 'ytick', [0.0:0.1:0.6], 'yticklabel', {'0%' '10%' '20%' '30%' '40%' '50%' '60%'});
    axis square;
    
    drawnow;
    set(gcf, 'Position', [   220    46   727   638]);


%% Raw plot of learning trajectories, without separation into inter/intra
function f = plot_raw_learning(cdata,ndata,ts,dtype,overlay)
%
    if ~exist('overlay','var'), overlay=false; end;
    
    f = figure;
    ddlbls = datatype_dependent_labels(dtype);
    
    % No noise first
    cc = ddlbls.colors{1};
    if ~overlay, subplot(1,2,1); end;
    hold on;
    
    set(gca, 'FontSize', 18);
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    lh1 = plot(ts.intact,      mean(cdata.intact(:,ts.intact),1), [cc '.-'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh2 = plot(ts.lesion,      mean(cdata.lesion,1),              [cc '.:'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    errorbar(ts.intact,  mean(cdata.intact(:,ts.intact),1), std(cdata.intact(:,ts.intact),[],1)/2, [cc '.']);
    errorbar(ts.lesion,  mean(cdata.lesion,1),              std(cdata.lesion,[],1)/2, [cc '.'])
    if ~overlay
        set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
        set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);
        set(gca, 'ytick', ddlbls.ytick, 'yticklabel', ddlbls.yticklabel);
        title('a) Learning Trajectory (control)');
        legend({'Intact', 'Lesioned' }, 'FontSize', 18);
    end;
    axis square;
    
    
    % Noise second
    nc = ddlbls.colors{2};
    if ~overlay, subplot(1,2,2); end;
    hold on;
    set(gca, 'FontSize', 18);
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    lh3 = plot(ts.intact,      mean(ndata.intact(:,ts.intact),1), [nc '.-'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    lh4 = plot(ts.lesion,      mean(ndata.lesion,1),              [nc '.:'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.intact,  mean(ndata.intact(:,ts.intact),1), std(ndata.intact(:,ts.intact),[],1)/2, [nc '.']);
    errorbar(ts.lesion,  mean(ndata.lesion,1),              std(ndata.lesion,[],1)/2, [nc '.'])
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);
    set(gca, 'ytick', ddlbls.ytick, 'yticklabel', ddlbls.yticklabel);
    axis square;
    
    if overlay
        title('Learning Trajectory');
        legend([lh1 lh2 lh3 lh4], {'Intact (control)', 'Lesioned (control)', 'Intact (noise)', 'Lesioned (noise)'}, 'FontSize', 18);
        
        drawnow;
        set(gcf, 'Position', [   220    46   727   638]);

    else
        title('b) Learning Trajectory (noise)');
        legend({'Intact', 'Lesioned' }, 'FontSize', 18);

        drawnow; 
        set(gcf, 'Position', [10          90        1266         594]);
    end;


%%
function ddlbls = datatype_dependent_labels(dtype)
%
    switch dtype
        case 'sse'
            ddlbls.title = 'Sum-squared error';
            ddlbls.ylbl = 'Sum-squared error';
            ddlbls.ylim = [0.0 1.0];
            ddlbls.ytick = [0.0:0.25:1.0];
            ddlbls.yticklabel = {'0' '0.25' '0.50' '0.75' '1.0'};
            
        case 'bce'
            ddlbls.title = 'Binary classification Error';
            ddlbls.ylbl = '% of wrongly classified outputs';
            ddlbls.ylim = [0.0 1.0];
            ddlbls.ytick = [0.0:0.25:1.0];
            ddlbls.yticklabel = {'0%' '25%' '50%' '75%' '100%'};
            
        otherwise
            error('Unknown datatype: %s', dtype);
    end;

    % Common to both
    ddlbls.colors  = {'b' 'r' 'g' 'k'};
    ddlbls.markers = {'*','v','s','o'};

    
  

