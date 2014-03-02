function [cc_add, c_add_mye, c_add_unmye, pct_mye, xvals] = predict_cc_add(brwt, bvol, xvals, pct_mye, fit_distn, frac, regress_type)
%function [cc_add, c_add_mye, c_add_unmye, pct_mye, xvals] = predict_cc_add(brwt, bvol, xvals, fit_distn, frac, regress_type)
%
% Fit Wang et al. (2008) data (myelinated & unmyelinated ADD), 
%   using FIT_DISTN distribution, then for each fiber type & parameter,
%   regress the parameter over brain weight.  
%
%   Finally, predict the parameters with the given brain weight, 
%   compute the distribution at each xval position, and combine 
%   myelinated and unmyelinated by predicting the pct myelinated fibers
%
%
% brwt
% bvol
% xvals: bins (defaults to Wang data)
% pct_mye: pct myelinated fibers (defaults to predict)
% fit_distn: gamma, lognormal, IUBD
% frac: only fit bars that have a minimum proportion of frac in the Wang et al. (2008) data
% regress_type: linear


    global g_cc_fit_distn g_cc_frac g_cc_regress_type
    global g_uparams g_mparams g_pmffn
    global g_cc_add_xvals g_cc_add g_cc_add_mye g_cc_add_unmye 
    global g_params_mye g_params_unmye
    
    if ~exist('fit_distn',    'var') || isempty(fit_distn),   fit_distn   =guru_iff(isempty(g_cc_fit_distn),   'gamma', g_cc_fit_distn); end;
    if ~exist('frac',        'var')  || isempty(frac),        frac        =guru_iff(isempty(g_cc_frac),        1/20, g_cc_frac); end;
    if ~exist('regress_type','var')  || isempty(regress_type),regress_type=guru_iff(isempty(g_cc_regress_type), 'linear', g_cc_regress_type); end;
    
    % Fit the distributions
    if isempty(g_cc_add) || ~strcmp(g_cc_fit_distn, fit_distn) || (isempty(g_cc_frac) || frac ~= g_cc_frac)
        g_cc_add = [];% 'g_cc_add';
        
        [fitfn,g_pmffn] = guru_getfitfns(fit_distn, frac, true);
        [g_uparams,g_mparams, g_cc_add_xvals] = fit_cc_add_params(fitfn);
        
        g_cc_fit_distn = fit_distn;
        g_cc_frac = frac;
    end;
    
    % Regress the distribution
    if isempty(g_cc_add) || ~strcmp(g_cc_regress_type, regress_type)
        [gmpm gmps gupm gups] = regress_cc_add_params(g_uparams, g_mparams, fit_distn, regress_type);
        
        g_cc_regress_type = regress_type;
        
        % Set up the functions
        g_params_mye   = @(brwt) ([gmpm(brwt) gmps(brwt)]);
        g_params_unmye = @(brwt) ([gupm(brwt) gups(brwt)]);
        g_cc_add_mye   = @(brwt, bins) g_pmffn(bins, g_params_mye(brwt));
        g_cc_add_unmye = @(brwt, bins) g_pmffn(bins, g_params_unmye(brwt));
        
        g_cc_add       = @(brwt, bins, pct_mye) (pct_mye.*g_cc_add_mye(brwt, bins) + (1-pct_mye)*g_cc_add_unmye(brwt,bins));
    end;
    
    % convert to native units
    if ~exist('brwt','var') || isempty(brwt),       brwt = predict_bwt(bvol); end;
    if ~exist('bvol','var'),                        bvol = []; end; % dummy just so we can easily call predict_pct_mye
    if ~exist('xvals','var') || isempty(xvals),     xvals = g_cc_add_xvals; end;
    if ~exist('pct_mye','var') || isempty(pct_mye), pct_mye     = predict_pct_mye(brwt, bvol); end;

    % Make the predictions
    cc_add      = g_cc_add(brwt, xvals, pct_mye);
    c_add_mye   = g_cc_add_mye(brwt, xvals);
    c_add_unmye = g_cc_add_unmye(brwt, xvals);

    
function [uparams,mparams,xvals] = fit_cc_add_params(fitfn)

    pd_dir = fileparts(which(mfilename));
    
    % Get the wang data
    addpath(fullfile(pd_dir, '..', '..', 'wang_etal_2008'));
    w_data;
    
    % KEY: subsample wang data
%    samples_step = floor(0.05/mean(diff(w_fig4_xvals)));
%    w_fig4_myelinated   = w_fig4_myelinated(:,1:samples_step:end);
%    w_fig4_unmyelinated = w_fig4_unmyelinated(:,1:samples_step:end);
%    w_fig4_xvals        = w_fig4_xvals(:,1:samples_step:end);
    
    % normalize distributions
    u_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_unmyelinated,2),[1 size(w_fig4_unmyelinated,2)]);
    m_distn = w_fig4_myelinated  ./repmat(sum(w_fig4_myelinated,2),  [1 size(w_fig4_myelinated,2)]);

    % Fit the distributions for each species
    nspecies = length(w_fig4_species);
    uparams  = nan(2,nspecies);
    mparams  = nan(2,nspecies);

    uf = figure; set(gcf, 'position', [27          17        1254         667])
    mf = figure; set(gcf, 'position', [27          17        1254         667])
    for si=1:nspecies
        % Fit unmyelinated
        figure(uf); subplot(2,ceil(nspecies/2),si);
        [ud, xvals] = smooth_distn(u_distn(si,:), w_fig4_xvals, 1, 1);
        uparams(:,si) = fitfn(ud, xvals);
        set(gca, 'xlim', [0 2.5], 'ylim', [0 0.3]);
        if si>1, legend('toggle'); end;
        if mod(si-1,ceil(nspecies/2))~=0, ylabel(''); end;
        if si>ceil(nspecies/2), xlabel('axon diameter ( {\mu}m)'); end;
        title(w_fig4_species{si});

        % Fit myelinated
        figure(mf); subplot(2,ceil(nspecies/2),si);
        [md, xvals] = smooth_distn(m_distn(si,:), w_fig4_xvals, 1, 1);
        mparams(:,si) = fitfn(md, xvals)
        set(gca, 'xlim', [0 2.5], 'ylim', [0 0.15]);
        if si>1, legend('toggle'); end;
        if mod(si-1,ceil(nspecies/2))~=0, ylabel(''); end;
        if si>ceil(nspecies/2), xlabel('axon diameter ( {\mu}m)'); end;
        title(w_fig4_species{si});
    end;

        
        
function [gmpm gmps gupm gups] = regress_cc_add_params(uparams, mparams, fit_distn, regress_type);
    pd_dir = fileparts(which(mfilename));

    % Get the wang data
    addpath(fullfile(pd_dir, '..', '..', 'wang_etal_2008'));
    w_data;
    
    switch regress_type
        case 'linear'
            switch fit_distn
                case {'IUBD','gamma'}

                    [pmpm,Rmpm] = polyfit(log10([w_fig4_brain_weights])', log10([mparams(1,:)]'), 1);
                    [pmps,Rmps] = polyfit(log10([w_fig4_brain_weights])', log10([mparams(2,:)]'), 1);
                    [pupm,Rupm] = polyfit(log10(w_fig4_brain_weights)', log10(uparams(1,:)'), 1);
                    [pups,Rups] = polyfit(log10(w_fig4_brain_weights)', log10(uparams(2,:)'), 1);

                    gmpm = @(wt) 10.^(polyval(pmpm, log10(wt)));
                    gmps = @(wt) 10.^(polyval(pmps, log10(wt), Rmps));
                    gupm = @(wt) 10.^(polyval(pupm, log10(wt), Rupm));
                    gups = @(wt) 10.^(polyval(pups, log10(wt), Rups));


                case {'lognormal'}

                    [pmpm,Rmpm] = polyfit(log10([w_fig4_brain_weights])', ([mparams(1,:)]'), 1);
                    [pmps,Rmps] = polyfit(log10([w_fig4_brain_weights])', ([mparams(2,:)]'), 1);
                    [pupm,Rupm] = polyfit(log10(w_fig4_brain_weights)', (uparams(1,:)'), 1);
                    [pups,Rups] = polyfit(log10(w_fig4_brain_weights)', (uparams(2,:)'), 1);

                    gmpm = @(wt) (polyval(pmpm, log10(wt)));
                    gmps = @(wt) (polyval(pmps, log10(wt), Rmps));
                    gupm = @(wt) (polyval(pupm, log10(wt), Rupm));
                    gups = @(wt) (polyval(pups, log10(wt), Rups));


            end;

            switch fit_distn
                case 'gamma',     yl1 = [0 20];  yl2 = [0 0.25]; pnames = {'k', '\theta'}; 
                case 'IUBD',      yl1 = [0 100]; yl2 = [0 100];  pnames = {'p1', 'p2'};
                case 'lognormal', yl1 = [0 20];  yl2 = [0 20];   pnames = {'\mu', '\sigma'};
            end;
            
            %logbw = log(w_fig4_brain_weights);
            bw_range = linspace(min(w_fig4_brain_weights), human_brain_weight, 100);
            %lbw_range = bw_range;%linspace(min(logbw), log(human_brain_weight), 100);

            % On parameters
            figure('Position', [94    33   751   651]);
            subplot(2,2,1); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, mparams(1,:), {'linear' 'log'});
    %        allometric_plot2(w_fig4_brain_weights, mparams(1,:),p,g,'linear',f_regress);
            loglog(w_fig4_brain_weights, [mparams(1,:)], 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gmpm(bw_range), 'LineWidth', 3);
            guru_smarttext(w_fig4_species, w_fig4_brain_weights, [mparams(1,:)],  gmpm(w_fig4_brain_weights)>[mparams(1,:)], 1.1)
            
            %xlabel('log_{10}(brain weight)');
            axis tight; set(gca, 'ylim', yl1)
            %ylabel(sprintf('%s value', pnames{1}));
            ylabel('parameter value');
            title(sprintf('myelinated %s',pnames{1}), 'FontSize', 16);

            subplot(2,2,2); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, mparams(2,:));
    %        allometric_plot2(w_fig4_brain_weights, mparams(2,:),p,g,'loglog',f_regress);
            loglog(([w_fig4_brain_weights]), [mparams(2,:)], 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gmps(bw_range), 'LineWidth', 3);
            guru_smarttext(w_fig4_species, w_fig4_brain_weights, [mparams(2,:)],  gmps(w_fig4_brain_weights)>[mparams(2,:)], 1.1)
            axis tight; set(gca, 'ylim', yl2)
            %xlabel('log_{10}(brain weight)'); 
            %ylabel(sprintf('%s value', pnames{2}));
            title(sprintf('myelinated %s', pnames{2}), 'FontSize', 16);

            subplot(2,2,3); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, uparams(1,:));
    %        allometric_plot2(w_fig4_brain_weights, uparams(1,:),p,g,'loglog',f_regress);
            loglog((w_fig4_brain_weights), uparams(1,:), 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gupm(bw_range), 'LineWidth', 3);
            guru_smarttext(w_fig4_species, w_fig4_brain_weights, [uparams(1,:)],  gupm(w_fig4_brain_weights)>[uparams(1,:)], 1.1)
            axis tight; set(gca, 'ylim', yl1)
            xlabel('brain weight (g)'); 
            %ylabel(sprintf('%s value', pnames{1}));
            ylabel('parameter value');
            title(sprintf('unmyelinated %s', pnames{1}), 'FontSize', 16);

            subplot(2,2,4); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, uparams(2,:));
    %        allometric_plot2(w_fig4_brain_weights, uparams(2,:),p,g,'loglog',f_regress);
            loglog((w_fig4_brain_weights), uparams(2,:), 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gups(bw_range), 'LineWidth', 3);
            guru_smarttext(w_fig4_species, w_fig4_brain_weights, [uparams(2,:)],  gups(w_fig4_brain_weights)>[uparams(2,:)], 1.1)
            axis tight; set(gca, 'ylim', yl2)
            %ylabel(sprintf('%s value', pnames{2});
            xlabel('brain weight (g)');
            title(sprintf('unmyelinated %s', pnames{2}), 'FontSize', 16);


        case 'linear_mv' % linear regression, but indirectly--using mean and variance
            error('broken');
            % Mean & variance for myelinated
            m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
            m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);
            [pmm,Rmm] = polyfit(log(w_fig4_brain_weights)', m_mean', 1);
            [pmv,Rmv] = polyfit(log(w_fig4_brain_weights)', m_var', 1);

            % Mean & variance for unmyelinated
            u_mean = exp(uparams(1,:)+uparams(2,:).^2/2);
            u_var  = (exp(uparams(2,:).^2)-1).*exp(2*uparams(1,:)+uparams(2,:).^2);
            [pum,Rum] = polyfit(log(w_fig4_brain_weights)', u_mean', 1);
            [puv,Ruv] = polyfit(log(w_fig4_brain_weights)', u_var', 1);

            gmm = @(wt) polyval(pmm, log(wt), Rmm);
            gmv = @(wt) polyval(pmv, log(wt), Rmv);
            gum = @(wt) polyval(pum, log(wt), Rum);
            guv = @(wt) polyval(puv, log(wt), Ruv);


            % go backwards to estimate mu and sigma from mean & variance
            % (1) m_mu = ln(mean)-sigma^2/2
            % m_var= (exp(sigma^2)-1).*exp(2*ln(mean)-sigma^2/2+sigma^2)
            m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
            m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);

            %logbw = log(w_fig4_brain_weights);
            bw_range = linspace(min(w_fig4_brain_weights), human_brain_weight, 100);
            lbw_range = log(bw_range);%linspace(min(logbw), log(human_brain_weight), 100);

            % On mean
            f_regress = figure; set(f_regress, 'Position', [94    33   751   651]);
            subplot(2,2,1); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), m_mean, 'o'); hold on;
            plot(lbw_range, polyval(pmm, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('mean value');
            title('myelinated mean (lognormal)', 'FontSize', 16);

            subplot(2,2,2); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), m_var, 'o'); hold on;
            plot(lbw_range, polyval(pmv, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('variance value');
            title('myelinated variance (lognormal)', 'FontSize', 16);

            subplot(2,2,3); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), u_mean, 'o'); hold on;
            plot(lbw_range, polyval(pum, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('mean value');
            title('unmyelinated mean (lognormal)', 'FontSize', 16);

            subplot(2,2,4); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), u_var, 'o'); hold on;
            plot(lbw_range, polyval(puv, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('variance value');
            title('unmyelinated mean (lognormal)', 'FontSize', 16);

        case 'gp'
            % Do the regressions for each parameter, and get 95% confidence
            % intervals
            lbw = log([w_fig4_brain_weights]);
            [hyp_mmu, inffunc_mmu, meanfunc_mmu, covfunc_mmu, likfunc_mmu] = gpreg(lbw', mparams(1,:)', true);
            [hyp_msg, inffunc_msg, meanfunc_msg, covfunc_msg, likfunc_msg] = gpreg(lbw', mparams(2,:)', true);
            [hyp_umu, inffunc_umu, meanfunc_umu, covfunc_umu, likfunc_umu] = gpreg(lbw', uparams(1,:)', true);
            [hyp_usg, inffunc_usg, meanfunc_usg, covfunc_usg, likfunc_usg] = gpreg(lbw', uparams(2,:)', true);

            xdist = max(lbw)-min(lbw);
            zx = [linspace(min(lbw)-xdist*.25, max(lbw)+xdist*.25, 25)'; log(human_brain_weight)]; % interpolate, and extrapolate by 25%

            [zm_mmu zs2_mmu] = gp(hyp_mmu, inffunc_mmu, meanfunc_mmu, covfunc_mmu, likfunc_mmu, lbw', mparams(1,:)', zx);
            [zm_msg zs2_msg] = gp(hyp_msg, inffunc_msg, meanfunc_msg, covfunc_msg, likfunc_msg, lbw', mparams(2,:)', zx);
            [zm_umu zs2_umu] = gp(hyp_umu, inffunc_umu, meanfunc_umu, covfunc_umu, likfunc_umu, lbw', uparams(1,:)', zx);
            [zm_usg zs2_usg] = gp(hyp_usg, inffunc_usg, meanfunc_usg, covfunc_usg, likfunc_usg, lbw', uparams(2,:)', zx);

            %     f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
            %    fill([z; flipdim(z,1)], f, [7 7 7]/8);

            % Compute the different curves
    end;

