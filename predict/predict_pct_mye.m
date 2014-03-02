function pct_mye = predict_pct_mye(brwt, bvol)
    

    global g_gmye;
    
    % convert to native units
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;

    
    %% Predict the % myelination
    if isempty(g_gmye)
        pd_dir = fileparts(which(mfilename));
        
        
        % Collect data, then predict!
        addpath(fullfile(pd_dir, '..', '..', 'aboitiz_etal_1992')); ab_data;
        addpath(fullfile(pd_dir, '..', '..', 'wang_etal_2008')); w_data;
        
        % Collect data
        human_pct_mye = 100*sum(ab_fig4_cc_rel_areas .* [.84 .95 .95 .95 .95]); %report that genu is 16% unmyelinated, the rest<5% unmyelinated
        
        [spec_wt,~,spec_idx] = unique(w_fig1c_weights);
        for ii=1:length(spec_wt), 
            mpmye(ii) = mean(w_fig1c_pctmye(spec_idx==ii)); 
        end;
        
        %figure; plot([spec_wt(1:end) 1300],  [mpmye(1:end) human_pct_mye]);

        x=linspace(spec_wt(1), 1300, 100);
%        figure ;plot(x, 100*(-0.6+1.54./(1+exp(-0.02*x)))); hold on;

        % sigmoid
        figure; set(gca, 'FontSize', 14);
        
        plot(x, 20+73*(atan(0.025*x)*2/pi), 'b--', 'LineWidth', 3); hold on;
        plot([spec_wt 1300], [mpmye(1:end) human_pct_mye], 'r*', 'MarkerSize', 5, 'LineWidth', 2)

        xlabel('brain weight (g)'); ylabel('%% myelinated fibers');
        
        % exponential decay
%        figure; plot(x, 8+80*exp(-x/10)); hold on;
%        plot([spec_wt 1300], 100-[mpmye(1:end) human_pct_mye], 'r*')
%        keyboard
        % Do the regression
        %[pmye,g_gmye] = allometric_regression([spec_wt(1:end) 1300], [mpmye(1:end) human_pct_mye], {'log','log'}, 1, true);
        %allometric_plot2([spec_wt 1300], [mpmye human_pct_mye], pmye, g_gmye);
        
        g_gmye = struct('y', @(brwt) (20+73*(atan(0.025*brwt)*2/pi)));
    end;
    
    pct_mye = g_gmye.y(brwt)/100;

%        pct_mye     = 0.92;
