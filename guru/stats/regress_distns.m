function [params,funs] = regress_distns(X,Y,fit_type,regress_type,order)

if ~exist('regress_type','var'), regress_type = 'linear'; end;
if ~exist('order','var'), order = 1; end;

idx = ~isnan(sum(Y,1));


params = zeros(order+1, size(Y,1));
funs   = cell(1, size(params));

switch regress_type
    case 'linear'
        switch fit_type
            case {'IUBD','gamma'}
                
                for ii=1:size(Y,1)
                    [params(:,ii),r] = polyfit(log(X(idx))', log(Y(ii,idx)'), order);
                    funs{ii} = @(wt) exp(polyval(params(:,ii), log(wt), r));
                end;

            case {'lognormal'}

                for ii=1:size(Y,1)
                    [params(:,ii),r] = polyfit(log(X(idx))', Y(ii,idx)', order);
                    funs{ii} = @(wt) polyval(params(:,ii), log(wt), r);
                end;
        
                
        end;

        %logbw = log(bi_fig9_dates);
        bw_range = linspace(min(X), max(X), 100);
        lbw_range = log(bw_range);%linspace(min(logbw), log(human_brain_weight), 100);

        % On parameters
        f_regress = figure; set(f_regress, 'Position', [94   366   950   318]);
        subplot(1,2,1); set(gca, 'FontSize', 14);
        plot(log([X]), [Y(1,:)], 'o'); hold on;
        plot(lbw_range, funs{1}(bw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('\mu value');
        title('myelinated \mu (lognormal)', 'FontSize', 16);

        subplot(1,2,2); set(gca, 'FontSize', 14);
        plot(log([X]), [Y(2,:)], 'o'); hold on;
        plot(lbw_range, funs{2}(bw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('\sigma value');
        title('myelinated \sigma (lognormal)', 'FontSize', 16);

        
    case 'linear_mv' % linear regression, but indirectly--using mean and variance
        error('xxx');
        % Mean & variance for myelinated
        m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
        m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);
        [pmm,Rmm] = polyfit(log(bi_fig9_dates)', m_mean', 1);
        [pmv,Rmv] = polyfit(log(bi_fig9_dates)', m_var', 1);

        % Mean & variance for unmyelinated
        u_mean = exp(uparams(1,:)+uparams(2,:).^2/2);
        u_var  = (exp(uparams(2,:).^2)-1).*exp(2*uparams(1,:)+uparams(2,:).^2);
        [pum,Rum] = polyfit(log(bi_fig9_dates)', u_mean', 1);
        [puv,Ruv] = polyfit(log(bi_fig9_dates)', u_var', 1);
        
        gmm = @(wt) polyval(pmm, log(wt), Rmm);
        gmv = @(wt) polyval(pmv, log(wt), Rmv);
        gum = @(wt) polyval(pum, log(wt), Rum);
        guv = @(wt) polyval(puv, log(wt), Ruv);
        

        % go backwards to estimate mu and sigma from mean & variance
        % (1) m_mu = ln(mean)-sigma^2/2
        % m_var= (exp(sigma^2)-1).*exp(2*ln(mean)-sigma^2/2+sigma^2)
        m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
        m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);

        %logbw = log(bi_fig9_dates);
        bw_range = linspace(min(bi_fig9_dates), max(bi_fig9_dates), 100);
        lbw_range = log(bw_range);%linspace(min(logbw), log(human_brain_weight), 100);

        % On mean
        f_regress = figure; set(f_regress, 'Position', [94    33   751   651]);
        subplot(2,2,1); set(gca, 'FontSize', 14);
        plot(log(bi_fig9_dates), m_mean, 'o'); hold on;
        plot(lbw_range, polyval(pmm, lbw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('mean value');
        title('myelinated mean (lognormal)', 'FontSize', 16);

        subplot(2,2,2); set(gca, 'FontSize', 14);
        plot(log(bi_fig9_dates), m_var, 'o'); hold on;
        plot(lbw_range, polyval(pmv, lbw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('variance value');
        title('myelinated variance (lognormal)', 'FontSize', 16);

        subplot(2,2,3); set(gca, 'FontSize', 14);
        plot(log(bi_fig9_dates), u_mean, 'o'); hold on;
        plot(lbw_range, polyval(pum, lbw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('mean value');
        title('unmyelinated mean (lognormal)', 'FontSize', 16);

        subplot(2,2,4); set(gca, 'FontSize', 14);
        plot(log(bi_fig9_dates), u_var, 'o'); hold on;
        plot(lbw_range, polyval(puv, lbw_range));
        xlabel('log_{10}(days post-conception)'); ylabel('variance value');
        title('unmyelinated mean (lognormal)', 'FontSize', 16);

    case 'gp'
        % Do the regressions for each parameter, and get 95% confidence
        % intervals
        lbw = log([bi_fig9_dates]);
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

