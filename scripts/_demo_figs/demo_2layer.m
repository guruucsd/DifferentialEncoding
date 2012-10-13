function [avg_resp, std_resp, bestofall] = demo_2layer(varargin)
%

    sz = [20 20];
    if (~exist('nbatches','var')), nbatches = 20; end;
    nsamps = 5;
    mode = 'std_lgs';
    thresh = 0.001;
    if (~exist('nin','var')), nin = 7; end;%round(177*.0);%round( prod(sz) * (0/100) ); %177 max
    fixed_wts = false;
    sigfact = 1;
    lambda = prod(sz)/nin;

    nphases = 5;
    norients= 5;
    %freqs = 0.015 * [ 6 9 12 15];
    freqs = 0.01 * [ 6 7.5 9 10.5];
    %freqs = freqs(end:-1:1);

    mu = 10+ [0 0]; 
    Sigma = [20 0;0 5]*sigfact; %20*eye(2);
    [X1,X2] = meshgrid([1:sz(1)]', [1:sz(2)]');
    X = [X1(:) X2(:)];

    w_init = reshape( mvnpdf(X, mu, Sigma), sz);
    w_init = double(w_init>thresh);
    nzw    = find(w_init);

    bestofall=zeros(nbatches*nsamps,1);
    avg_resp = zeros(nbatches*nsamps, length(freqs));
    std_resp = zeros(nbatches*nsamps, length(freqs));
    resps = zeros(length(freqs),norients,nphases);

    niters = 1;

    for jj = 1:nbatches
        for ii=1:nsamps
            sampnum = (jj-1)*nsamps+ii;

            w     = zeros(size(w_init));%w_init;
            inidx = randperm(nnz(w_init));

            rnd = abs(randn(size(nzw(inidx(1:min(nin,nnz(w_init)))))));
            if fixed_wts, rnd = ones(size(rnd)); end;

            w(nzw(inidx(1:min(nin,nnz(w_init))))) = 0.01*rnd;
            w = w / sum(w(:));


            %surf(X1,X2,reshape(p,sz));


            best_vals = -inf*ones(size(freqs));
            best_params = zeros(length(freqs), 3);
            best_x = zeros(length(freqs), prod(sz));

            for fi=1:length(freqs)
                ci = 1;

                % Find the best fit orientation and phase
                for oi = 1:norients
                    orient = pi*oi/norients;
                    for phsi=1:nphases
                        phase = 2*pi*phsi/nphases;

                        x = 0.5+mfe_grating2d( freqs(fi), phase, orient, 0.5, sz(1), sz(2));
                        resp = x(:)/sum(x(:));
                        for ixi=1:niters
                            resp = sum(resp.*w(:));
                        end;
                        resps(fi,oi,phsi) = sum(resp);

                        if (best_vals(fi)<resps(fi,oi,phsi))
                            best_vals(fi)     = resps(fi,oi,phsi);
                            best_params(fi,:) = [freqs(fi) orient phase];
                            best_x(fi,:)      = x(:);
                        end;
                        ci = ci + 1;
                    end;
                end;
            end;


            % normalize
            resps_by_freq = reshape(resps, [length(freqs) norients*nphases]);
            resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));

            switch mode
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

                case {'mean_lgs','avg_lgs', 'total_lgs'}
                    resps = tanh(lambda*resps);
                    resps_by_freq = reshape(resps, [length(freqs) norients*nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = avg_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(avg_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'std_lgs','range_lgs'}
                    resps = 1/(1+exp(-lambda*resps));
                    resps_by_freq = reshape(resps, [length(freqs) norients*nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = std_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(std_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'mean_sqd','avg_sqd', 'total_sqd'}
                    resps = resps.^2;
                    resps_by_freq = reshape(resps, [length(freqs) norients*nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = avg_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(avg_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case {'std_sqd','range_sqd'}
                    resps = resps.^2;
                    resps_by_freq = reshape(resps, [length(freqs) norients*nphases]);
                    resps_by_freq_norm = resps_by_freq/mean(resps_by_freq(:));
                    avg_resp(sampnum,:) = mean(resps_by_freq_norm,2);
                    std_resp(sampnum,:) = std(resps_by_freq_norm,[],2);
                    best_vals = std_resp(sampnum,:);
                    [~,bestofall(sampnum)] = max(std_resp(sampnum,:));%max(mean(mean(resps,3),2));

                case 'range', 
                    rng  = max(alld') - min(alld');
                    [~,bestofall(sampnum)] = max(rng);

                otherwise, error('%s nyi', mode);
            end;
        end;
    end;

