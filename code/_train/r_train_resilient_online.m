function [net,data] = r_train_resilient_online(net,pats)
    net.sets.online = false; 
    ns = net.sets;
    
    tic;
    stt = toc();

    %%%%%%%%%%%%%%
    % Initialization
    %%%%%%%%%%%%%%
    
    %network 
    upidx  = 1+[1:net.nunits-1];  %update input, hidden & output units
    outidx = 1+net.ninput+net.nhidden+[1:net.noutput];
    oi     = 1:net.noutput;

    % Error
    data.good_update = true(ns.niters,1);
    E               = zeros(ns.niters,pats.npat,pats.tsteps,net.noutput, 'single');
    data.E_pat      = zeros(ns.niters,pats.npat,net.noutput, 'single');           % error
    data.E_lesion   = zeros(floor(ns.niters/ns.test_freq),pats.npat,net.noutput, 'single');           % error
    data.E_iter     = zeros(ns.niters,1, 'single');
    data.learncurve = zeros(ns.niters,pats.npat,net.noutput,'single');
    data.actcurve   = zeros(pats.tsteps,pats.npat,net.noutput,'single');
    data.cccurve    = zeros(pats.tsteps,pats.npat,length(net.idx.cc),'single');

    % main program
    % Initialize values
    net.w_init  = net.w; net.T_init = net.T; net.D_init = net.D;

    if (ns.online)
        dw_pat   = zeros(pats.npat,size(net.w,1),size(net.w,2)); %change in weights over time
        dwr_pat  = zeros(size(dw_pat));
        
        dT_pat   = zeros(pats.npat,length(net.T));
        dTr_pat  = zeros(size(dT_pat));
        
        dD_pat   = zeros(pats.npat,size(net.D,1),size(net.D,2)); %change in weights over time
        dDr_pat  = zeros(size(dD_pat));
    end;
    dw           = zeros(size(net.w));
    dT           = zeros(size(net.T));
    dD           = zeros(size(net.D));
    dwr          = zeros(size(net.w)); % last iteration's dw
    dTr          = zeros(size(net.T)); % last iteration's dT
    dDr          = zeros(size(net.D)); % last iteration's dD
 
    etas_w    = ns.eta_w*single(net.cC);     
    etas_T    = ns.eta_T*ones(size(net.T)); 
    etas_D    = ns.eta_D*single(net.cC);     
    lambdas_w = ns.lambda_w*single(net.cC);
    lambdas_T = ns.lambda_T*ones(size(net.T));
    lambdas_D = ns.lambda_D*single(net.cC);

    v_wl0     = zeros(size(net.w));
    v_Tl0     = zeros(size(net.T));
    v_Dl0     = zeros(size(net.D));
    osc_w     = zeros(size(net.w));
    osc_T     = zeros(size(net.T));
    osc_D     = zeros(size(net.D));
    noosc_w     = zeros(size(net.w));
    noosc_T     = zeros(size(net.T));
    noosc_D     = zeros(size(net.D));
    

    % "Fan-in" etas (p. 339)
    fidx = net.idx.fan;
%    etas_w(fidx.core,fidx.core)  = etas_w(fidx.core,fidx.core)./repmat(net.fan_in(fidx.core), [length(fidx.core) 1]);
%    etas_w(fidx.bias,:)          = etas_w(fidx.bias,:)./mean(net.fan_in);
%    etas_T(fidx.core)            = etas_T(fidx.core)./net.fan_in(fidx.core)';
%    etas_T(fidx.bias)            = etas_T(fidx.bias)./mean(net.fan_in);
%    etas_D(fidx.core,fidx.core)  = etas_D(fidx.core,fidx.core)./repmat(net.fan_in(fidx.core), [length(fidx.core) 1]);
%    etas_D(fidx.bias,:)          = etas_D(fidx.bias,:)./mean(net.fan_in);

%    lambdas_w(fidx.core,fidx.core)  = lambdas_w(fidx.core,fidx.core)./repmat(net.fan_in(fidx.core), [length(fidx.core) 1]);
%    lambdas_w(fidx.bias,:)          = lambdas_w(fidx.bias,:)./mean(net.fan_in);
%    lambdas_T(fidx.core)            = lambdas_T(fidx.core)./net.fan_in(fidx.core)';
%    lambdas_T(fidx.bias)            = lambdas_T(fidx.bias)./mean(net.fan_in);
%    lambdas_D(fidx.core,fidx.core)  = lambdas_D(fidx.core,fidx.core)./repmat(net.fan_in(fidx.core), [length(fidx.core) 1]);
%    lambdas_D(fidx.bias,:)          = lambdas_D(fidx.bias,:)./mean(net.fan_in);


    % Initialize storage

    % Forward pass
    I     = zeros(pats.tsteps,net.nunits,'single');
    x     = zeros(pats.tsteps,net.nunits);
    fx    = zeros(size(x));
    fpx   = zeros(size(x));
    y     = zeros(pats.tsteps,net.nunits);
    dy    = zeros(size(y));
    
    % Backward pass
    z       = zeros(pats.tsteps+1,net.nunits);
    dz      = zeros(size(z));
    e       = zeros(pats.tsteps,net.nunits,'single');         % "instantaneous error"
    gradE_w = zeros(pats.tsteps,size(net.w,1), size(net.w,2));
    gradE_D = zeros(pats.tsteps,size(net.D,1), size(net.D,2));
    gradE_T = zeros(pats.tsteps,length(net.T));


    if (ns.verbose), r_printPats(data); end;


    %%%%%%%%%%%%%%
    % Main Loop
    %%%%%%%%%%%%%%

    pcIter = 1; %iteration where a param change was made
    
    for iter=1:ns.niters
        fprintf('[%4d]: ',iter);

        % Random order for online
        if (ns.online), porder = randperm(pats.npat);
        else,                 porder = 1:pats.npat; end;
        
        

        % Save old values
        if (~ns.online)
            dw(:,:) = net.w.*ns.wt_wts; %starting pio
            dT(:) = 0;
            dD(:,:) = 0;
        end;
        

        
        for pi=1:pats.npat
            p = porder(pi);

            %%%%%%%%%%%%%%%%
            % Simulate forward
            %%%%%%%%%%%%%%%%

            I(:,1:1+net.ninput) = reshape(pats.P(:,p,:), [pats.tsteps 1+net.ninput]);  % current external input from current input pattern
            e(:,:)              = 0;
            
            dt_div_T            = ns.dt./net.T;       % pre-calculate commonly used value
            
            %y(:) = 0;
            for ti=1:pats.tsteps

                % Calculate dy and y
                if (ti==1)
                    dy(1,:)     = 0;
                    y (1,:)     = I(1,:) + net.fn.f(0); %for sigmoid, set bias input to 0.5, so added to 0.5, you get 1.0!
                else
                    dy(ti,:)     = 0;
                    dy(ti,upidx) = dt_div_T(upidx)' .* (-y(ti-1,upidx) + fx(ti-1,upidx) + I(ti,upidx)); %p88, eqn4
                    y (ti,:)     = y(ti-1,:) + dy(ti,:);
                end;
                
                % Calculate x and fx SECOND.  Y precedes x; so y(ti) should ref
                % x(ti-1) and x(ti) should ref y(ti)
                % Use most efficient time-indexing function to compute x(t)
                x(ti,:)   = sum(net.w.*net.fn.r_backdel1(ti,y,net.D),1);
                fx(ti,:)  = net.fn.f(x(ti,:));
                fpx(ti,:) = net.fn.fp(fx(ti,:));
                
                
                e(ti, outidx)      = net.fn.Errp(reshape(pats.s(ti,p,:),[1 net.noutput]), ...
                                                y(ti,outidx), ...
                                                reshape(pats.d(ti,p,:),[1 net.noutput]), ...
                                                ns.grad_pow) ...
                                     .*((1-ns.wt_class)+ns.wt_class*(abs(y(ti,net.idx.output)-reshape(pats.d(ti,p,:),[1 net.noutput]))>ns.train_criterion));
                                     
                E(iter,p,ti,:)     = net.fn.Err(reshape(pats.s(ti,p,:),[1 net.noutput]), ...
                                                y(ti,outidx), ...
                                                reshape(pats.d(ti,p,:),[1  net.noutput]));
        
                if any(isnan(x(ti,:)))
                    error('why nan???');
                end;
            end;
            
            % Save some stats
            data.E_pat(iter,p,:)      = ns.dt*sum(E(iter,p,:,:),3);
            data.learncurve(iter,p,:) = y(end,outidx);
            data.actcurve(:,p,:)      = y(:,[outidx]);
            data.cccurve(:,p,:)       = y(:, net.idx.cc);
    

            %%%%%%%%%%%%%%
            % Simulate backwards
            %%%%%%%%%%%%%%
            
            dz(end,:)        = 0;
            z(end,:)         = 0;
            for ti = pats.tsteps:-1:1
                % Get values by delay
                dy_d  = net.fn.r_backdel1(ti,dy,net.D);
                fpx_d = net.fn.r_fwddel1(ti,fpx,net.D);
                z_d   = net.fn.r_fwddel1(ti+1,z,net.D);
            
                dz(ti,:) = (ns.dt.*(-z(ti+1,:)'./net.T + e(ti,:)' + ns.wt_act.*y(ti,:)' + sum(net.w.*(fpx_d.*z_d)',2)./net.T))'; %p88, eqn5
                z(ti,:)  = z(ti+1,:) + dz(ti,:);

                gradE_w(ti,:,:) = (ns.dt.*repmat(y(ti,:), [net.nunits 1]).*fpx_d.*z_d./repmat(net.T,[1 net.nunits]))';
                gradE_D(ti,:,:) = (ns.dt.*repmat(z(ti,:)',[1 net.nunits]).*repmat(fpx(ti,:)',[1 net.nunits]).*net.w'.*dy_d')';
                gradE_T(ti,:)   = -z(ti+1,:).*dy(ti,:)./net.T';     %p89, eqn2.4.  note we use dy instead of dy/dt.*dt, and with no delay
            end;
            

            %%%%%%%%%%%%%%
            % Calc network update parameters
            %%%%%%%%%
            
            % Do weight and time constant changes
%                dw = dw + reshape(sum(gradE_w,1), size(dw));
%                dT = dT + reshape(sum(gradE_T,1), size(dT));
%                dD = dD + reshape(sum(gradE_D,1), size(dD));
            dw_pat(p,:,:) = sum(gradE_w,1); %p88, eqn 8 (integrate over time)
            dT_pat(p,:,:) = sum(gradE_T,1); %p88, eqn 9 (integrate over time)
            dD_pat(p,:,:) = sum(gradE_D,1); %p88, eqn 8 (integrate over time)
                
            if (ns.online)
                error('online backprop broken');
            
                if (pi == pats.npat)
                    dw = reshape(sum(dw_pat,1), size(net.w));
                    dT = reshape(sum(dT_pat,1), size(net.T));
                    dD = reshape(sum(dD_pat,1), size(net.D));
                end;
                
                % weights
                net.w   = net.w - (1-ns.alpha_w).*etas_w.*net.cC.*reshape(dw_pat(p,:,:),  size(net.w));
                net.w   = net.w -    ns.alpha_w .*etas_w.*net.cC.*reshape(dwr_pat(p,:,:), size(net.w)); 
                net.w   = min(max(net.w,ns.W_LIM(1)),ns.W_LIM(2));

                % time constants
                net.T   = net.T - (1-ns.alpha_T).*etas_T.*reshape(dT_pat(p,:),  size(net.T));
                net.T   = net.T -    ns.alpha_T .*etas_T.*reshape(dTr_pat(p,:), size(net.T)); 
                net.T   = min(max(net.T,ns.T_LIM(1)),ns.T_LIM(2)); %

                % delays
                net.Df  = net.Df - (1-ns.alpha_D).*etas_D.*net.cC.*reshape(dD_pat(p,:,:),  size(net.D));
                net.Df  = net.Df -    ns.alpha_D .*etas_D.*net.cC.*reshape(dDr_pat(p,:,:), size(net.D)); 
                net.Df  = min(max(net.Df,ns.D_LIM(1)),ns.D_LIM(2));
                net.D   = round(net.Df); %
            end;
        end; %for p = 1:npats

        
        %%%%%%%%%%%%%%
        % 
        %%%%%%%%%%%%%%

        % Calc some stats
        data.E_iter(iter) = sum(sum(data.E_pat(iter,:,:)));

        % 
        abs_diff         = abs(data.actcurve-pats.d).*pats.s;
        max_diff         = max(abs_diff(:));
        bits_cor         = (abs_diff<ns.train_criterion).*pats.s;
        bits_set         = length(find(pats.s));
        pats_cor         = all(bits_cor,2);
        pats_set         = bits_set/pats.npat;

        %
        if (mod(iter,ns.test_freq)==0)
            [td] = r_test(net,pats,data,true);
            data.E_lesion(round(iter/ns.test_freq),:,:) = td.E(end,:,:);
            clear('td');
        end;

        % Do some reporting
        fprintf('Err=%6.2e;  eta( w=%5.2e )', data.E_iter(iter), mean(etas_w(find(etas_w))));
        fprintf(' (%4.1f%% bt /%4.1f%% pat);  maxdiff=(%4.3f)', ...
                100*sum(bits_cor(:))/bits_set, ...
                100*sum(pats_cor(:))/pats_set, ...
                max_diff);
        if (ns.verbose && mod(iter,ns.test_freq)==0), abs_diff, end;
        
            
        % We trained to criterion; break out!
        if (sum(bits_cor(:)) == bits_set)
            fprintf('\n\tHey!  Done early!\n');
            data.niters = iter;
            break;
        end;

        
        %%%%%%%%%%%%%%
        % Judge whether the current update was better than the previous
        %%%%%%%%%%%%%%

        % 
        giters = iter+1-find(data.good_update(iter:-1:1),3); %good iterations
        %pat_touse = ~all(squeeze(sum(bits_cor,1)==sum(pats.s,1)));
        dw(:) = sum(dw_pat,1); %only train on patterns we didn't solve yet.
        dT(:) = sum(dT_pat,1);
        dD(:) = sum(dD_pat,1);
        
        dw = dw.*net.cC; dD = dD.*net.cC;

        % Calculate for delta-bar - delta rule
        v_w   = dwr.*dw; v_T   = dTr.*dT; v_D   = dDr.*dD;

        v_wl0 = v_w<0;   v_Tl0 = v_T<0;   v_Dl0 = v_D<0;
        v_wg0 = v_w>0;   v_Tg0 = v_T>0;   v_Dg0 = v_D>0;
        v_we0 = v_w==0;  v_Te0 = v_T==0;  v_De0 = v_D==0;
 
        etaw_toch = (1 + (v_wl0>0)) .* (v_w<0);
        etaT_toch = (1 + (v_Tl0>0)) .* (v_T<0); 
        etaD_toch = (1 + (v_Dl0>0)) .* (v_D<0);
            
        % Detect unexpected case
        if (iter > 1 && (all(v_we0(:)) || all(v_Te0(:)) || all(v_De0(:))))
            warning('Nothing is happening; might as well quit :(.');
            net.failed = true;
            break;
        end;

        % Slightly modified delta-bar - delta rule: 
        %   Only care about changes that are above some 
        %   threshhold value
        etaw_toch = v_wl0;
        etaT_toch = v_Tl0; 
        etaD_toch = v_Dl0;
            
        fprintf('  sign-change=(%4.1f%% /%4.1f%%)', ...
                100*length(find(v_wl0))/length(find(net.cC)), ...
                100*length(find(v_Tl0))/length(net.T));

        if (length(giters)>1)
            rel_error  = (data.E_iter(iter) - data.E_iter(giters(2)))/(data.E_iter(iter));
        end;
        less_error = length(giters)==1 || rel_error<ns.REL_E_MAX; %allow a little bit of up-error
        few_bad_weight_changes = length(find(etaw_toch)) <= (ns.bad_pct_w)*numel(v_w);
        few_bad_tc_changes     = length(find(etaT_toch)) <= (ns.bad_pct_T)*numel(v_T);
        few_bad_delay_changes  = length(find(etaD_toch)) <= (ns.bad_pct_D)*numel(v_D);

        data.good_update(iter) = less_error && 1<=sum(few_bad_weight_changes + few_bad_tc_changes + few_bad_delay_changes);
        
        % 
        if (~data.good_update(iter))
            fprintf(' *** ');
            
            % Roll back parameter changes
            net.w = wm1; etas_w = etas_wm1/2; %binary search
            net.T = Tm1; etas_T = etas_Tm1/2;
            net.D = Dm1; etas_D = etas_Dm1/2;

            % Roll back advancing frame of parameter change history
            dw     = dwr;      dT     = dTr;      dD     = dDr;
            if (ns.online)
                dw_pat = dwr_pat;  dT_pat = dTr_pat;  dD_pat = dDr_pat;
            end;


            % How frequently are bad iterations happening?
            winsize       = 50;
            if (~exist('last_update','var') || (iter-last_update) > winsize/2.5)
                recent_update = data.good_update(max(iter-winsize,1):iter);
                nbad          = sum(~recent_update);
                streaks       = diff(find(diff(recent_update)==1));
                
                if (nbad > winsize*0.15)
                    fprintf('\n\t15%% bad iterations means, i''m shrinking your lambda!\n');
                    lambdas_w = lambdas_w/2; lambdas_T = lambdas_T/2; lambdas_D = lambdas_D/2;
                    last_update = iter;
                end;
                if (length(find(streaks==1))>=winsize*0.05)
                    fprintf('\n\t5%% consecutive bad iterations means, i''m increasing your phi!\n');
                    phi_w = min(phi_w*1.25,1); phi_T = min(phi_T*1.25,1); phi_D = min(phi_D*1.25,1);
                    last_update = iter;     
                end;
                    
                if ((nbad > winsize*0.33) && length(find(etaw_toch))==0)
                    fprintf('\n\tThinking about switching to batch mode!\n');
%                    batch = false;
                    last_update = iter;
                end;
            end;    


            giters = giters(2:end);
                
            % now, re-try an update with these scaled-back params
        end; % if ~good_iter

        wm1 = net.w; etas_wm1 = etas_w;
        Tm1 = net.T; etas_Tm1 = etas_T;
        Dm1 = net.D; etas_Dm1 = etas_D;
        dwr = dw;    dTr = dT; dDr = dD;
        if (ns.online)
            dwr_pat = dw_pat;
            dTr_pat = dT_pat;
            dDr_pat = dD_pat;
        end;
        
        %%%%%%%%%%%%%%
        % Batch update
        %%%%%%%%%%%%%%


        if (~ns.online)
            % weights
            dwi  = sign(dw); dwir = sign(dwr);
            
            net.w   = net.w - (1-ns.alpha_w).*etas_w.*net.cC.*dwi;
            net.w   = net.w -    ns.alpha_w .*etas_w.*net.cC.*dwir; 
            net.w   = min(max(net.w,ns.W_LIM(1)),ns.W_LIM(2));
            
            % time constants
            dTi  = sign(dT); dTir = sign(dTr);
            
            net.T   = net.T - (1-ns.alpha_T).*etas_T.*dTi;
            net.T   = net.T -    ns.alpha_T .*etas_T.*dTir; 
            net.T   = min(max(net.T,ns.T_LIM(1)),ns.T_LIM(2)); %

            % delays
            dDi  = sign(dD); dDir = sign(dDr);
            
            net.Df  = net.Df - (1-ns.alpha_D).*etas_D.*net.cC.*dDi;
            net.Df  = net.Df -    ns.alpha_D .*etas_D.*net.cC.*dDir; 
            net.Df  = min(max(net.Df,ns.D_LIM(1)),ns.D_LIM(2));
            net.D   = round(net.Df); %

        end;

        %%%%%%%%%%%%%%
        % Parameter updates 
        %%%%%%%%%%%%%%
        
        if (data.good_update(iter))

            % Look for oscillations
            osc_w = (1 + osc_w) .* v_wl0;
            osc_T = (1 + osc_T) .* v_Tl0;
            osc_D = (1 + osc_D) .* v_Dl0;
        
            noosc_w = (1 + noosc_w) .* v_wg0;
            noosc_T = (1 + noosc_T) .* v_Tg0;
            noosc_D = (1 + noosc_D) .* v_Dg0;
        
            fprintf('  cycles=(+%2d/-%2d +%2d/-%2d)', ...
                    length(find(osc_w>2)), length(find(noosc_w>3)), ...
                    length(find(osc_T>2)), length(find(noosc_T>3)) );

            lambdas_w(osc_w>2) = lambdas_w(osc_w>2) .* (1-ns.phi_w);
            lambdas_T(osc_T>2) = lambdas_T(osc_T>2) .* (1-ns.phi_T);
            lambdas_D(osc_D>2) = lambdas_D(osc_D>2) .* (1-ns.phi_D);

            if (iter > 1 && diff(data.E_iter(iter-1:iter))<0)
                lambdas_w(noosc_w>3) = lambdas_w(noosc_w>3) .* (1+0.2./noosc_w(noosc_w>3));
                lambdas_T(noosc_T>3) = lambdas_T(noosc_T>3) .* (1+0.2./noosc_T(noosc_T>3));
                lambdas_D(noosc_D>3) = lambdas_D(noosc_D>3) .* (1+0.2./noosc_D(noosc_D>3));
            end;


            if (false && iter > 5 && (data.E_iter(iter)-data.E_iter(iter-5))>0)
                %fprintf('\n\tWent up ...');
                if (any(diff(data.E_iter(iter-5:iter))<0))
                    %fprintf(' ... but no harm, no foul.\n');
                else
                    fprintf('\n\tWent up... cut lambdas back!!\n');
                    lambdas_w = lambdas_w/2; lambdas_T = lambdas_T/2; lambdas_D = lambdas_D/2;
                    etas_w = etas_w - etas_w.*ns.phi_w;
                    etas_T = etas_T - etas_T.*ns.phi_T;
                    etas_D = etas_D - etas_D.*ns.phi_D;
                end;
            end;
            
            
            % Look for funky behavior
            if ((iter - pcIter) >= 50)
                
                if ( (0.95 < data.E_iter(iter)/data.E_iter(iter-50)) )
                    df     = diff(data.E_iter(iter-50:iter));
                    cyclic = (length(find(df>0))>=0.1*50);
                    
%                    ns.wt_act = ns.wt_act/2;%*(1-ns.phi_w);
%                    ns.wt_wts = ns.wt_wts/2;%*(1-ns.phi_w);
                    
%                    etas_w = etas_w*10;
                    
                    if (cyclic)
                        if (sum(df(df>0)) > -0.67*sum(df(df<0)))
                            fprintf('\n\tReduced error by only %5.2f%% in %d iterations; cycles detected, so REDUCE!', 100*(1-data.E_iter(iter)/data.E_iter(iter-50)), 50);

                            v_wg0 = false(size(v_wg0));  v_Tg0 = false(size(v_Tg0));  v_Dg0 = false(size(v_Dg0)); 
                            v_wl0 = true(size(v_wl0));   v_Tl0 = true(size(v_Tl0));   v_Dl0 = true(size(v_Dl0)); 
                        else
                            fprintf('\n\tSkipping semi-cyclic, slow descent\n');
                        end;
                    else
                        fprintf('\n\tReduced error by only %5.2f%% in %d iterations; no cycles, so BOOST!', 100*(1-data.E_iter(iter)/data.E_iter(iter-50)), 50);

                        v_wg0 = true(size(v_wg0));    v_Tg0 = true(size(v_Tg0));    v_Dg0 = true(size(v_Dg0)); 
                        v_wl0 = false(size(v_wl0));   v_Tl0 = false(size(v_Tl0));   v_Dl0 = false(size(v_Dl0)); 
                        
                        v_wg0 = 1/(1-ns.phi_w).^5*v_wg0;v_Tg0 = 1/(1-ns.phi_T).^5*v_Tg0;v_Dg0 = 1/(1-ns.phi_D).^5*v_Dg0;
                    end;
                
                    pcIter    = iter;
                    %ns.mxw   = ns.mxw .* fact;
                end;             
            end;
            
        end;
            
        if (isfield(ns,'lambda_w')), kappas_w = lambdas_w.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        if (isfield(ns,'lambda_T')), kappas_T = lambdas_T.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        if (isfield(ns,'lambda_D')), kappas_D = lambdas_D.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        
        if (iter > 1 && diff(data.E_iter(iter-1:iter))<0)
            etas_w = etas_w + v_wg0.*kappas_w;
            etas_D = etas_D + v_Dg0.*kappas_D;
            etas_T = etas_T + v_Tg0.*kappas_T;
        end;
        
        etas_w = etas_w - etas_w.*v_wl0.*(ns.phi_w);
        etas_T = etas_T - etas_T.*v_Tl0.*(ns.phi_T);
        etas_D = etas_D - etas_D.*v_Dl0.*(ns.phi_D);
        
        if (ns.eta_w_min && mean(etas_w(:))<ns.eta_w_min), etas_w = etas_w*ns.eta_w_min/mean(etas_w(:)); end;
        if (ns.eta_T_min && mean(etas_T(:))<ns.eta_T_min), etas_T = etas_T*ns.eta_T_min/mean(etas_T(:)); end;
        if (ns.eta_D_min && mean(etas_D(:))<ns.eta_D_min), etas_D = etas_D*ns.eta_D_min/mean(etas_D(:)); end;
        
        fprintf('\n');
    end;
    
    
    
    % Cut unused pre-allocated space
    data.good_update = data.good_update(1:iter);
    data.E_pat       = data.E_pat(1:iter,:,:);
    data.E_lesion    = data.E_lesion(1:floor(iter/100),:,:);
    data.E_iter      = data.E_iter(1:iter);
    data.learncurve  = data.learncurve(1:iter,:,:);
    data.y           = y;
    
    net.sets = ns; % save off any changes
    
    % Fill in at last iteration
%    data.actcurve    = zeros(pats.tsteps,pats.npat,net.noutput,'single');
%    data.cccurve     = zeros(pats.tsteps,pats.npat,length(net.idx.cc),'single');
