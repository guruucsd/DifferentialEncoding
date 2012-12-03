function [net,data] = r_train_resilient_batch(net,pats)
    ns = net.sets;
            
    %%%%%%%%%%%%%%
    % Initialization
    %%%%%%%%%%%%%%
    
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

    % Learning steps (and past copies)
    dw           = zeros(size(net.wC));
    dT           = zeros(size(net.TC));
    dD           = zeros(size(net.DC));
    dwr          = zeros(size(dw)); % last iteration's dw
    dTr          = zeros(size(dT)); % last iteration's dT
    dDr          = zeros(size(dD)); % last iteration's dD
 
    % For variable learning rate
    if (numel(ns.eta_w)==1),    ns.eta_w    = ns.eta_w   .*ones(size(net.wC),'single'); end;
    if (numel(ns.eta_T)==1),    ns.eta_T    = ns.eta_T   .*ones(size(net.TC),'single'); end;
    if (numel(ns.eta_D)==1),    ns.eta_D    = ns.eta_D   .*ones(size(net.DC),'single'); end;
    if (numel(ns.lambda_w)==1), ns.lambda_w = ns.lambda_w.*ones(size(net.wC),'single'); end;
    if (numel(ns.lambda_T)==1), ns.lambda_T = ns.lambda_T.*ones(size(net.TC),'single'); end;
    if (numel(ns.lambda_D)==1), ns.lambda_D = ns.lambda_D.*ones(size(net.DC),'single'); end;

    % For detecting oscillating value changes
    osc_w     = zeros(size(net.wC));    noosc_w     = zeros(size(net.wC));
    osc_T     = zeros(size(net.TC));    noosc_T     = zeros(size(net.TC));
    osc_D     = zeros(size(net.DC));    noosc_D     = zeros(size(net.DC));
    

    % Forward pass
    I     = zeros(pats.tsteps,pats.npat,net.nunits);
    x     = zeros(pats.tsteps,pats.npat,net.nunits);
    fx    = zeros(size(x));
    fpx   = zeros(size(x));
    y     = zeros(pats.tsteps,pats.npat,net.nunits);
    dy    = zeros(size(y));
    
    % Backward pass
    z       = zeros(pats.tsteps,pats.npat,net.nunits);
    dz      = zeros(size(z));
    e       = zeros(pats.tsteps,pats.npat,net.nunits);         % "instantaneous error"
    gradE_w = zeros(pats.tsteps,pats.npat,size(net.w,1), size(net.w,2));
    gradE_D = zeros(pats.tsteps,pats.npat,size(net.D,1), size(net.D,2));
    gradE_T = zeros(pats.tsteps,pats.npat,length(net.T));


    %%%%%%%%%%%%%%
    % Initialize indexing
    %%%%%%%%%%%%%%
    global backIdx fwdIdx  biIdx  biIncr;
    global upidx   outidx;
    
    r_init_indices(net,pats);


    %%%%%%%%%%%%%%
    % Main Loop
    %%%%%%%%%%%%%%

    if (ns.verbose), r_printPats(data); end;

    I(:,:,1:1+net.ninput) = pats.P;  %patterns defined for input nodes; I is for all nodes
    pcIter              = 1;       %iteration where a param change was made
    

    for iter=1:ns.niters
        fprintf('[%4d]: ',iter);

        %%%%%%%%%%%%%%%%
        % Simulate forward
        %%%%%%%%%%%%%%%%

        dy(:)         = 0; %must be done
        e(:)          = 0; %must be done
        
        w_repd        = repmat(reshape(net.w, [1 size(net.w)]), [pats.npat 1 1]);
        T_repd        = repmat(reshape(net.T, [1 size(net.T')]),[1 pats.npat 1]);
        D_repd        = repmat(reshape(net.D, [1 size(net.D)]), [pats.npat 1 1]);
        
        dt_div_T_repd = ns.dt./T_repd;       % pre-calculate commonly used value
        
        for ti=1:pats.tsteps
            bi = (backIdx{biIdx(ti)}+biIncr(ti));
            
            % Calculate dy and y
            if (ti==1)
                %dy(1,:,:)     = 0;
                y (1,:,:)     = I(1,:,:) + net.fn.f(0) + net.sets.noise_init*(randn(size(y(1,:,:))));
            else
                %dy(ti,:,:)     = 0;
                dy(ti,:,upidx) = dt_div_T_repd(:,:,upidx) .* (-y(ti-1,:,upidx) + fx(ti-1,:,upidx) + I(ti,:,upidx) + net.sets.noise_input*(randn(size(y(ti,:,upidx))))); %p88, eqn4
                y (ti,:,:)     = y(ti-1,:,:) + dy(ti,:,:);
            end;
            
            % Calculate x and fx SECOND.  Y precedes x; so y(ti) should ref
            % x(ti-1) and x(ti) should ref y(ti)
            % Use most efficient time-indexing function to compute x(t)
            y_d         = y(bi).*(ti>=D_repd);
            x(ti,:,:)   = sum(w_repd .* y_d, 2);
            fx(ti,:,:)  = net.fn.f(x(ti,:,:));
            fpx(ti,:,:) = net.fn.fp(fx(ti,:,:));
            
            e(ti, :, outidx) = net.fn.Errp(pats.s(ti,:,:), ...
                                           y(ti,:,outidx), ...
                                           pats.d(ti,:,:), ...
                                           ns.grad_pow) ...
                                          .*((1-ns.wt_class)+ns.wt_class*(abs(y(ti,:,outidx)-pats.d(ti,:,:))>ns.train_criterion));
                                 
            E(iter,:,ti,:)   = net.fn.Err(pats.s(ti,:,:), y(ti,:,outidx), pats.d(ti,:,:));
    
            %if (any(any( dy(ti,:,:)==pi))),     error('why dy nan???'); end;
            %if (any(any( y (ti,:,:)==pi))),     error('why y nan???'); end;
            %if (any(any( y_d       ==pi))),     error('why y_d nan???'); end;
            %if (any(any( e(ti,:,outidx)==pi))), error('why dy nan???'); end;
            
            %if (any(any( isnan(E(iter,:,ti,:)) ))), error('E is nan'); end;
        end;

        % Save some stats
        data.E_pat(iter,:,:)      = ns.dt*sum(E(iter,:,:,:),3);
        data.learncurve(iter,:,:) = y(end,:,outidx);
        data.actcurve             = y(:,:,[outidx]);
        data.cccurve              = y(:,:,net.idx.cc);
    
        %%%%%%%%%%%%%%
        % Simulate backwards
        %%%%%%%%%%%%%%

        dz(:) = 0;
        z(:) = 0;
%        dz(end,:,:)        = pi;
%        z (end,:,:)        = pi;
        for ti = pats.tsteps:-1:1
            bi = (backIdx{biIdx(ti)}+biIncr(ti));
            %fi = (fwdIdx{fiIdx(ti)}+fiIncr(ti));
            
            % Get arguments via delay
            dy_d             = dy (bi)           .* (ti>=D_repd); %net.fn.r_backdel1b(ti,dy,D_repd);%
            fpx_d            = fpx(fwdIdx{ti})   .* (ti<(pats.tsteps  -D_repd));
            z_d              = z  (fwdIdx{ti+1}) .* (ti<(pats.tsteps  -D_repd)); %(size(z,1)-D(:))>ti),

            %if (any(dy_d (:)==pi)), error('why dy_d nan???'); end;
            %if (any(fpx_d(:)==pi)), error('why fpx_d nan???'); end;
            %if (any(z_d  (:)==pi)), error('why z_d nan???'); end;

            if (ti<pats.tsteps)
                dz(ti,:,:)  =   - dt_div_T_repd .* z(ti+1,:,:) ...
                                + ns.dt         .* e(ti,:,:) ...
                                + dt_div_T_repd .* reshape(sum(permute(w_repd,[1 3 2]).*(fpx_d.*z_d),2),size(T_repd));
                                %p88, eqn5
                z(ti,:,:)   = z(ti+1,:,:) + dz(ti,:,:);
            else
                dz(ti,:,:)  =   ns.dt         .* e(ti,:,:) ...
                              + dt_div_T_repd .* reshape(sum(permute(w_repd,[1 3 2]).*(fpx_d.*z_d),2),size(T_repd));
                                %p88, eqn5
                z(ti,:,:)   = dz(ti,:,:);
            end;
           
            %yy      = ; %this is wrong; should vary over row
            %fpxz_d  = reshape(fpx_d.*z_d, [1 size(z_d)]);                        %vary over column
            %T_rrepd = repmat(T_repd,[1 1 1 net.nunits]);
            
            gradE_w(ti,:,:,:) = permute( ...
                                       permute(repmat(y(ti,:,:), [1 1 1 net.nunits]), [1 2 4 3]) ...
                                    .* reshape(fpx_d.*z_d, [1 size(z_d)]) ...
                                    .* repmat(dt_div_T_repd,[1 1 1 net.nunits]) ...
                                , [1 2 4 3]); %yy.*fpxz_d./T_rrepd,[1 2 4 3]);
                        

%            flipped = 0;
%            for i=1:net.nunits
%                for j=1:net.nunits
%                    for p=1:pats.npat
%                        gradE_wij_t = ns.dt*y(ti,p,i)*fpx_d(p,i,j)*z_d(p,i,j)/T_repd(1,p,j);
%                            if (yy(1,p,j,i)     ~= y(ti,p,i)), error('y'); end;
%                            if (fpxz_d(1,p,i,j) ~= fpx_d(p,i,j)*z_d(p,i,j)), error('fpxz_d'); end;
%                            if (T_rrepd(1,p,i,j) ~= T_repd(1,p,j)), error('T_rrepd'); end;
%                        if (gradE_w(ti,p,i,j) - gradE_wij_t > 1E-10)
%                                keyboard;
%                        end;
%                    end;
%                end;
%            end;
            
            

            gradE_D(ti,:,:,:) = 1;%ns.dt.*repmat(z(ti,:,:).*fpx(ti,:,:),[1 1 1 net.nunits]).*reshape(w_repd.*dy_d, [1 size(w_repd)]);
            gradE_T(ti,:,:)   = 1;%-zp1.*dy(ti,:,:)./T_repd;     %p89, eqn2.4.  note we use dy instead of dy/dt.*dt, and with no delay
        end;

        %%%%%%%%%%%%%%
        % 
        %%%%%%%%%%%%%%

        % Calc some stats
        data.E_iter(iter) = sum(sum(data.E_pat(iter,:,:)));

        % 
        abs_diff         = abs(data.actcurve(pats.gb)-pats.d(pats.gb));
        max_diff         = max(abs_diff(:));
        bits_cor         = (abs_diff<ns.train_criterion);
        bits_set         = length(pats.gb);

        %
        if (mod(iter,ns.test_freq)==0)
            nl = r_lesion_cc(net);
            td = r_forwardpass(nl,pats,data);

            data.E_lesion(round(iter/ns.test_freq),:,:) = td.E(end,:,:);
            clear('nl','td');
        end;

        % Do some reporting
        fprintf('Err=%6.2e; (%4.1f%% bt ) maxdiff=(%4.3f);', ...
                data.E_iter(iter), ...
                floor(1000*sum(bits_cor(:))/bits_set)/10.0, ...
                max_diff);
        if (ns.verbose && mod(iter,ns.test_freq)==0), abs_diff, end;
        
            
        % We trained to criterion; break out!
        if (sum(bits_cor(:)) == bits_set)
            fprintf('\n\tHey!  Done early!\n');
            if (net.sets.noise_input > 0)
                % We should test here on non-noisy patterns
                fprintf('\t[note; Due to noise, we may not have trained to 100% for the non-noisy patterns...]\n');
            end;
            data.niters = iter;
            break;
        end;

        
        %%%%%%%%%%%%%%
        % Judge whether the current update was better than the previous
        %%%%%%%%%%%%%%

        % 
        giters = iter+1-find(data.good_update(iter:-1:1),3); %good iterations
        %pat_touse = ~all(squeeze(sum(bits_cor,1)==sum(pats.s,1)));
        
            
        %%%%%%%%%%%%%%
        % Calc network update parameters
        %%%%%%%%%
        dw(:) = sum(sum(gradE_w,2),1); %sum over patterns and time
        dT(:) = squeeze(sum(sum(gradE_T,2),1));
        dD(:) = squeeze(sum(sum(gradE_D,2),1));
        ;
        dw = dw.*net.wC; dD = dD.*net.DC; dT = dT.*net.TC;

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
            break;
        end;

        % Slightly modified delta-bar - delta rule: 
        %   Only care about changes that are above some 
        %   threshhold value
        etaw_toch = v_wl0;
        etaT_toch = v_Tl0; 
        etaD_toch = v_Dl0;
            
        fprintf('  eta( w=%6.2e )',  mean(ns.eta_w(find(ns.eta_w))));
        fprintf('  sign-change=(%4.1f%% /%4.1f%%)', ...
                100*length(find(v_wl0))/length(find(net.wC)), ...
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
            net.w = wm1; ns.eta_w = ns.eta_wm1/2; %binary search
            net.T = Tm1; ns.eta_T = ns.eta_Tm1/2;
            net.D = Dm1; ns.eta_D = ns.eta_Dm1/2;

            % Roll back advancing frame of parameter change history
            dw     = dwr;      dT     = dTr;      dD     = dDr;


            % How frequently are bad iterations happening?
            winsize       = 50;
            if (~exist('last_update','var') || (iter-last_update) > winsize/2.5)
                recent_update = data.good_update(max(iter-winsize,1):iter);
                nbad          = sum(~recent_update);
                streaks       = diff(find(diff(recent_update)==1));
                
                if (nbad > winsize*0.15)
                    fprintf('\n\t15%% bad iterations means, i''m shrinking your lambda!\n');
                    ns.lambda_w = ns.lambda_w/2; ns.lambda_T = ns.lambda_T/2; ns.lambda_D = ns.lambda_D/2;
                    last_update = iter;
                end;
                if (length(find(streaks==1))>=winsize*0.05)
                    fprintf('\n\t5%% consecutive bad iterations means, i''m increasing your phi!\n');
                    phi_w = min(phi_w*1.25,1); phi_T = min(phi_T*1.25,1); phi_D = min(phi_D*1.25,1);
                    last_update = iter;     
                end;
                    
                if ((nbad > winsize*0.33) && isempty(find(etaw_toch)))
                    fprintf('\n\tThinking about switching to batch mode!\n');
%                    batch = false;
                    last_update = iter;
                end;
            end;    


            giters = giters(2:end);
                
            % now, re-try an update with these scaled-back params
        end; % if ~good_iter

        wm1 = net.w; ns.eta_wm1 = ns.eta_w;
        Tm1 = net.T; ns.eta_Tm1 = ns.eta_T;
        Dm1 = net.D; ns.eta_Dm1 = ns.eta_D;
        dwr = dw;    dTr = dT; dDr = dD;
        
        %%%%%%%%%%%%%%
        % Batch update
        %%%%%%%%%%%%%%

        % weights
        dwi  = sign(dw); dwir = sign(dwr);
        
        net.w   = net.w - (1-ns.alpha_w).*ns.eta_w.*net.wC.*dwi;
        net.w   = net.w -    ns.alpha_w .*ns.eta_w.*net.wC.*dwir; 
        net.w   = min(max(net.w,ns.W_LIM(1)),ns.W_LIM(2));
        net.w(net.idx.cc,net.idx.cc) = min(max(net.w(net.idx.cc,net.idx.cc),ns.cc_wt_lim(1)),ns.cc_wt_lim(2));
        
        net.w   = (1-net.sets.w_decay)*net.w;
        
        % time constants
        dTi  = sign(dT); dTir = sign(dTr);
        
        net.T   = net.T - (1-ns.alpha_T).*ns.eta_T.*net.TC.*dTi;
        net.T   = net.T -    ns.alpha_T .*ns.eta_T.*net.TC.*dTir; 
        net.T   = min(max(net.T,ns.T_LIM(1)),ns.T_LIM(2)); %

        % delays
        dDi  = sign(dD); dDir = sign(dDr);
        
        net.Df  = net.Df - (1-ns.alpha_D).*ns.eta_D.*net.DC.*dDi;
        net.Df  = net.Df -    ns.alpha_D .*ns.eta_D.*net.DC.*dDir; 
        net.Df  = min(max(net.Df,ns.D_LIM(1)),ns.D_LIM(2));
        net.D   = round(net.Df); %

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

            ns.lambda_w(osc_w>2) = ns.lambda_w(osc_w>2) .* (1-ns.phi_w);
            ns.lambda_T(osc_T>2) = ns.lambda_T(osc_T>2) .* (1-ns.phi_T);
            ns.lambda_D(osc_D>2) = ns.lambda_D(osc_D>2) .* (1-ns.phi_D);

            if (iter > 1 && diff(data.E_iter(iter-1:iter))<0)
                ns.lambda_w(noosc_w>3) = ns.lambda_w(noosc_w>3) .* (1+0.2./noosc_w(noosc_w>3));
                ns.lambda_T(noosc_T>3) = ns.lambda_T(noosc_T>3) .* (1+0.2./noosc_T(noosc_T>3));
                ns.lambda_D(noosc_D>3) = ns.lambda_D(noosc_D>3) .* (1+0.2./noosc_D(noosc_D>3));
            end;


            if (false && iter > 5 && (data.E_iter(iter)-data.E_iter(iter-5))>0)
                %fprintf('\n\tWent up ...');
                if (any(diff(data.E_iter(iter-5:iter))<0))
                    %fprintf(' ... but no harm, no foul.\n');
                else
                    fprintf('\n\tWent up... cut lambdas back!!\n');
                    ns.lambda_w = ns.lambda_w/2; ns.lambda_T = ns.lambda_T/2; ns.lambda_D = ns.lambda_D/2;
                    ns.eta_w = ns.eta_w - ns.eta_w.*ns.phi_w;
                    ns.eta_T = ns.eta_T - ns.eta_T.*ns.phi_T;
                    ns.eta_D = ns.eta_D - ns.eta_D.*ns.phi_D;
                end;
            end;
        end;
            
        if (isfield(ns,'lambda_w')), kappas_w = ns.lambda_w.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        if (isfield(ns,'lambda_T')), kappas_T = ns.lambda_T.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        if (isfield(ns,'lambda_D')), kappas_D = ns.lambda_D.*(data.E_iter(giters(1))/(diff(ns.S_LIM)/ns.dt)); end;
        
        if (iter > 1 && diff(data.E_iter(iter-1:iter))<0)
            ns.eta_w = ns.eta_w + v_wg0.*kappas_w;
            ns.eta_D = ns.eta_D + v_Dg0.*kappas_D;
            ns.eta_T = ns.eta_T + v_Tg0.*kappas_T;
        end;
        
        ns.eta_w = ns.eta_w - ns.eta_w.*v_wl0.*(ns.phi_w);
        ns.eta_T = ns.eta_T - ns.eta_T.*v_Tl0.*(ns.phi_T);
        ns.eta_D = ns.eta_D - ns.eta_D.*v_Dl0.*(ns.phi_D);
        
        if (ns.eta_w_min && mean(ns.eta_w(:))<ns.eta_w_min), ns.eta_w = ns.eta_w*ns.eta_w_min/mean(ns.eta_w(:)); end;
        if (ns.eta_T_min && mean(ns.eta_T(:))<ns.eta_T_min), ns.eta_T = ns.eta_T*ns.eta_T_min/mean(ns.eta_T(:)); end;
        if (ns.eta_D_min && mean(ns.eta_D(:))<ns.eta_D_min), ns.eta_D = ns.eta_D*ns.eta_D_min/mean(ns.eta_D(:)); end;
        
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
