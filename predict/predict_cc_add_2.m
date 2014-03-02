function [p,distn,m_distn,u_distn,pct_mye] = predict_cc_fiber_distn(brwt, bvol, fittype, bins, regress_type, showfig)
    
    global g_gmpm g_gmps g_gupm g_gups
    global g_gmye
    
    % convert to native units
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;

    if ~exist('fittype','var'), fittype='gamma'; end;
    if ~exist('bins','var'),    bins = linspace(0,4,100); end;
    if ~exist('regress_type','var'), regress_type = 'linear'; end;
    if ~exist('showfig','var'), showfig = true; end;
    
    [fitfn,pmffn] = getfitfns(fittype);
    pd_dir = fileparts(which(mfilename));
    
    %% Get the wang data, fit and regress the distributions
    addpath(fullfile(pd_dir, '..', '..', 'wang_etal_2008'));
    w_data;
    if isempty(g_gmps)%','var')
        addpath(genpath(fullfile(pd_dir, '..', '..', '..', '_lib')));
        w_fit_distns;
        w_regress_distns;
        
        g_gmpm = gmpm; g_gmps = gmps; 
        g_gupm = gupm; g_gups = gups;
    end;


    %% Predict distribution parameters
    switch regress_type
        case 'linear'
            m_p = [g_gmpm(brwt) g_gmps(brwt)];
            u_p = [g_gupm(brwt) g_gups(brwt)];
        case 'linear_mv'
            error('?');
            m_p = [gmm(brwt) gmv(brwt)];
            u_p = [gum(brwt) guv(brwt)];

            % back-predict mu and sigma
            m_p = [mufn(m_p(1), m_p(2)) sigmafn(m_p(1), m_p(2))];
            u_p = [mufn(u_p(1), u_p(2)) sigmafn(u_p(1), u_p(2))];

        otherwise, error('unknown regress type: %s', w_regress_type);
    end;

    %% Predict the % myelination
    if isempty(g_gmye)
        % Collect data, then predict!
        addpath(fullfile(pd_dir, '..', '..', 'aboitiz_etal_1992')); ab_data;
        human_pct_mye = 100*sum(ab_fig4_cc_rel_areas .* [.84 .95 .95 .95 .95]); %report that genu is 16% unmyelinated, the rest<5% unmyelinated
        [spec_wt,~,spec_idx] = unique(w_fig1c_weights);
        for ii=1:length(spec_wt), mpmye(ii) = mean(w_fig1c_pctmye(spec_idx==ii)); end;
        [pmye,g_gmye] = allometric_regression([spec_wt(2:end) 1300], [mpmye(2:end) human_pct_mye], {'log','log'}, 1, true, '');
        allometric_plot2([spec_wt 1300], [mpmye human_pct_mye], pmye, g_gmye);
    end;
    pct_mye = g_gmye.y(brwt)/100;

    
    % Create the prediction
    m_distn = @(bins) pmffn(bins, m_p(1), m_p(2));
    u_distn = @(bins) pmffn(bins, u_p(1), u_p(2));
    distn   = @(bins) (pct_mye*m_distn(bins) + (1-pct_mye)*u_distn(bins));


    figure; p = fitfn(distn(bins), bins); close(gcf);

    if showfig
        % Plot the results:
        figure('position', [139   297   909   387]);

        % subplot 1: myelinated and unmyelinated distributions
        subplot(1,2,1);
        bh = bar(bins, u_distn(bins), 1, 'r', 'EdgeColor','r');
        hold on;
        bar(bins, m_distn(bins), 1, 'b', 'EdgeColor','b');
        ch = get(bh,'child');
        set(ch,'facea',.5)
        axis tight;%set(gca, 'ylim', [0 0.60], 'xlim', [0 4]);
        legend({'unmyelinated','myelinated'});
        title('Predicted histograms');

        % subplot 2: show the predicted and smoothed aboitiz distns
        subplot(1,2,2);
        bh = bar(bins, distn(bins),1,'b');
        hold on;
        plot(bins, pmffn(bins, p(1), p(2)), 'r--', 'LineWidth', 2);
        title('Predicted (combined) histograms vs. data');
        set(gca, 'xlim', bins([1 end]));
        legend(bh, {'Predicted data'})
    end;
    
