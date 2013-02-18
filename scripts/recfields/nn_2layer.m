function [avg_resp, std_resp, bestofall, wts, p] = nn_2layer(varargin)
%

    addpath(genpath('../../code'));
    de_SetupExptPaths('sergent_1982');

    p = struct( 'seed', rand(1), ...
                'sz', [20 20], ... %image size
                'img2pol', false, ...
                'nbatches', 20, ... %
                'nsamps', 5, ...
                'a_mode', 'mean', ... % activation mode
                'c_mode', 'pdf',     ... % connectivity mode
                'w_mode', 'posmean', ... % weight mode
                'distn', 'norme2', ...
                'thresh', 0.001, ...
                'dfromcent', 3, ...
                'disp',false,...
                'nin', 177, .... %round(177*.0);%round( prod(sz) * (0/100) ); %177 max
                'nphases', 8, ...
                'norients', 8, ...
                'niters', 1, ...  % # times to feed output back to input
                'cpi', [0.5 1 2 4 8 16 32] ...% freqs', 0.01 * [ 1.5 3 6 12 18 24 30 36 42 48 54] ...    %freqs = 0.015 * [ 6 9 12 15];
              );
    p = guru_stampProps(p, varargin{:});

    if isfield(p, 'freqs'), error('freqs should not be set. please set cpi!'); end;
    p.freqs = p.cpi./max(p.sz); %cycles
        
    % Set param values that are dependent on other param values
    if (~isfield(p, 'mu')),     p.mu     = p.sz/2; end;
    if (~isfield(p, 'Sigma')),  p.Sigma  = [2*p.sz(1) 0; 0 0.5*p.sz(2)]; end;
    if (~isfield(p, 'lambda')), p.lambda = prod(p.sz)/p.nin; end;

    rand('seed', p.seed);
    randn('seed', p.seed);
    
    % Create grid of points for calculating images
    [X1,X2] = meshgrid([1:p.sz(1)]', [1:p.sz(2)]');
    X = [X1(:) X2(:)];

    % Initialize variables
    bestofall= zeros(p.nbatches*p.nsamps,1);
    avg_resp = zeros(p.nbatches*p.nsamps, length(p.freqs));
    std_resp = zeros(p.nbatches*p.nsamps, length(p.freqs));
    resps = zeros(length(p.freqs),p.norients,p.nphases);
    wts   = zeros([p.nbatches*p.nsamps, p.sz]);
    for jj = 1:p.nbatches
        for ii=1:p.nsamps
            sampnum = (jj-1)*p.nsamps+ii;

            % Determine weights
            [~, Wts] = de_connector(struct( 'nInput',  p.sz, ...
                                          'nHidden', 1, ...
                                          'hpl',     1,...
                                          'nConns',  p.nin, ...
                                          'distn',   {{p.distn}}, ...
                                          'mu',      0,...
                                          'sigma',   p.Sigma(1),...
                                          'ac', struct('debug', 0, 'tol', 1-p.nin/prod(p.sz), 'useBias', 0, 'WeightInitScale', 0.01, 'WeightInitType', 'randn') ...
                                         ));
            w = reshape(Wts(2+prod(p.sz),1:prod(p.sz)), p.sz);
            switch (p.w_mode)
                case {'fixed'},    w = double(w ~= 0); %set to 1
                case {'posmean'},  w = abs(w);
                case {'negmean'},  w = -abs(w);
                case {'zeromean'}, w = w - mean(w(:));
                case {'gauss'},
                    w_pdf = reshape( mvnpdf(X, p.mu, p.Sigma), p.sz);
                    w = (w ~= 0) .* sign(w) .* w_pdf;
                case {'center-surround'} % weight is based on distance from center (both magnitude (gauss), and sign (mex-hat))
                  dfromcent = reshape(sqrt(sum((X - repmat(p.mu,[prod(p.sz) 1])).^2,2)), p.sz);
                  w_pdf1 = reshape( mvnpdf(X, p.mu, 0.75*p.Sigma), p.sz);
                  w_pdf2 = reshape( mvnpdf(X, p.mu, 1.25*p.Sigma), p.sz);
                  w = (w ~= 0) .* (w_pdf1-1.05*w_pdf2);
                  %imagesc(w_pdf1-0.5*w_pdf2); colorbar;
                otherwise, error('unknown weight mode: %s', p.w_mode);
            end;
            %w = w / max(abs(sum(w(:))), 1); %p.nin; %sum(abs(w(:))); %implicitly dividing by p_in
            wts(sampnum, :,:) = w;

            %
            best_vals = -inf*ones(size(p.freqs));
            best_params = zeros(length(p.freqs), 3);
            best_x = zeros(length(p.freqs), prod(p.sz));

            for fi=1:length(p.freqs)
                ci = 1;

                % Find the best fit orientation and phase
                for oi = 1:p.norients
                    orient = 2*pi*oi/p.norients; % oi starts at 1, so essentially [0 to pi)
                    for phsi=1:p.nphases
                        phase = 2*pi*phsi/p.nphases; %pi starts at 1, so essentially [0 to 2pi)

                        x = 0.5+mfe_grating2d( p.freqs(fi), phase, orient, 0.5, p.sz(1), p.sz(2));
                        if p.img2pol, x = mfe_img2pol(x); end;
                        if ismember(1, p.disp) && oi==1 && phsi==1 && jj==1 && ii==1
                            if fi==1, f=figure; [nrows,ncols] = guru_optSubplots(length(p.freqs));
                            else, figure(f); end;
                            subplot(nrows,ncols,fi);
                            imshow(x); xlabel(sprintf('frq=%.4f',p.freqs(fi)));
                        end;
                        
                        % Calculate output node response
                        resp = x(:)/sum(x(:));
                        for ixi=1:p.niters
                            resp = sum(resp.*w(:));
                        end;
                        resps(fi,oi,phsi) = sum(resp);

                        if (best_vals(fi)<resps(fi,oi,phsi))
                            best_vals(fi)     = resps(fi,oi,phsi);
                            best_params(fi,:) = [p.freqs(fi) orient phase];
                            best_x(fi,:)      = x(:);
                        end;
                        ci = ci + 1;
                    end;
                end;
            end;


            % normalize
            resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
            resps_by_freq_norm = resps_by_freq;%/mean(resps_by_freq(:));

            switch p.a_mode
                case 'max'
                    [~,bestofall(sampnum)] = max(best_vals);

                case {'mean','total'}
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);

                    best_vals = avg_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(avg_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'std'}
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2)';%./avg_resp(sampnum,:)';
                    best_vals = std_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(std_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'mean_lgs','avg_lgs', 'total_lgs'} % run through logistic
                    resps = tanh(p.lambda*resps);
                    resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = avg_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(avg_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'std_lgs','range_lgs'} % run through logistic
                    resps = 1/(1+exp(-p.lambda*resps));
                    resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = std_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(std_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'mean_sqd','avg_sqd', 'total_sqd'}
                    resps = resps.^2;
                    resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = avg_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(avg_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'std_sqd','range_sqd'}
                    resps = resps.^2;
                    resps_by_freq = reshape(resps, [length(p.freqs) p.norients*p.nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = std_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(std_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case 'range', 
                    rng  = max(alld') - min(alld');
                    [~,bestofall(sampnum)] = max(rng);

                otherwise, error('%s nyi', p.a_mode);
            end;
        end;
    end;

