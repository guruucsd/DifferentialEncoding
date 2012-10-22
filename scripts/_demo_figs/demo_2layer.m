function [avg_resp, std_resp, bestofall] = demo_2layer(varargin)
%

    addpath(genpath('../../code'));

    p = struct( 'sz', [20 20], ... %image size
                'nbatches', 20, ... %
                'nsamps', 5, ...
                'a_mode', 'std_lgs', ... % activation mode
                'c_mode', 'pdf',     ... % connectivity mode
                'w_mode', 'posmean', ... % weight mode
                'thresh', 0.001, ...
                'dfromcent', 3, ...
                'nin', 7, .... %round(177*.0);%round( prod(sz) * (0/100) ); %177 max
                'nphases', 8, ...
                'norients', 8, ...
                'niters', 1, ...  % # times to feed output back to input
                'freqs', 0.01 * [ 6 7.5 9 10.5] ...    %freqs = 0.015 * [ 6 9 12 15];
              );
    p        = guru_stampProps(p, varargin{:});
    % Set param values that are dependent on other param values
    if (~isfield(p, 'mu')),     p.mu     = p.sz/2; end;
    if (~isfield(p, 'Sigma')),  p.Sigma  = [2*p.sz(1) 0; 0 0.5*p.sz(2)]; end;
    if (~isfield(p, 'lambda')), p.lambda = prod(p.sz)/p.nin; end;


    % Create grid of points for calculating images
    [X1,X2] = meshgrid([1:p.sz(1)]', [1:p.sz(2)]');
    X = [X1(:) X2(:)];

    % Get PDF map (static over all)
    w_pdf = reshape( mvnpdf(X, p.mu, p.Sigma), p.sz);

    % Initialize variables
    bestofall= zeros(p.nbatches*p.nsamps,1);
    avg_resp = zeros(p.nbatches*p.nsamps, length(p.freqs));
    std_resp = zeros(p.nbatches*p.nsamps, length(p.freqs));
    resps = zeros(length(p.freqs),p.norients,p.nphases);

    for jj = 1:p.nbatches
        for ii=1:p.nsamps
            sampnum = (jj-1)*p.nsamps+ii;

            % Select connections according to PDF
            switch p.c_mode
                case {'thresh'},
                    w_pdf = double(w_pdf>p.thresh);
                    inidx = randperm(nnz(w_pdf))';

                case {'pdf'}, % sample without replacement
                  w_pdf_idx = 1:numel(w_pdf);
                  w_cdf = [0 cumsum(w_pdf(w_pdf_idx))];
                  inidx = zeros(p.nin,1);
                  for ci=1:p.nin
                    inidx(ci) = find(w_cdf>=rand()*w_cdf(end), 1)-1;
                    w_pdf_idx = setdiff(w_pdf_idx,inidx(ci));
                    w_cdf = [0 cumsum(w_pdf(w_pdf_idx))];
                  end;
            end;
            inidx = inidx(1:min(p.nin,length(inidx)));

            % Determine weights
            w     = zeros(p.sz);%spatial map of weights;
            switch (p.w_mode)
                case {'fixed'},    w(inidx) = ones(size(inidx));
                case {'posmean'},  w(inidx) = abs(randn(size(inidx)));
                case {'negmean'},  w(inidx) = -abs(randn(size(inidx)));
                case {'zeromean'}, w(inidx) = randn(size(inidx));
                case {'center-surround'} % weight is based on distance from center (both magnitude (gauss), and sign (mex-hat))
                  dfromcent = sqrt(sum((X(inidx,:) - repmat(p.mu,[length(inidx) 1])).^2,2));
                  w(inidx) = w_pdf(inidx) .* (1-2*(dfromcent > p.dfromcent));
                otherwise, error('unknown weight mode: %s', p.w_mode);
            end;
            w = w / sum(abs(w(:)));

            %
            best_vals = -inf*ones(size(p.freqs));
            best_params = zeros(length(p.freqs), 3);
            best_x = zeros(length(p.freqs), prod(p.sz));

            for fi=1:length(p.freqs)
                ci = 1;

                % Find the best fit orientation and phase
                for oi = 1:p.norients
                    orient = pi*oi/p.norients;
                    for phsi=1:p.nphases
                        phase = 2*pi*phsi/p.nphases;

                        x = 0.5+mfe_grating2d( p.freqs(fi), phase, orient, 0.5, p.sz(1), p.sz(2));
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
            resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));

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
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
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

