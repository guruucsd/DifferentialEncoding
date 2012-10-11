clear all; close all;
addpath(genpath('../../code'))

sz = [20 20];
nbatches = 20;
nsamps = 5;
mode = 'std_lgs';
thresh = 0.001;
nin = 7;%round(177*.0);%round( prod(sz) * (0/100) ); %177 max
fixed_wts = false;
sigfact = 1;
lambda = 1/nin;

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

figure; 
set(gcf,'Position',[ 84         -21        1014         705]);


bestofall=zeros(nbatches*nsamps,1);
avg_resp = zeros(nbatches*nsamps, length(freqs));
std_resp = zeros(nbatches*nsamps, length(freqs));
resps = zeros(length(freqs),norients,nphases);

niters = 10;

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

        % row 1, center col: receptive field weights
        subplot(3,length(freqs), floor((length(freqs)-1)/2 ));
        imagesc(w);
        colormap gray;
        axis square; axis image;
        set(gca,'xtick',[],'ytick',[]);
        title('Weights', 'FontSize',18);

        gridfreq  = 1;
        huloc     = sz/2;    % position of hidden unit in center of image
        subplot(3,length(freqs), floor((length(freqs)-1)/2 +1));
        cla;
        hold on;
        
        daspect(gca, [1 1 1/10])

        [a,b] = find(w>0);
        cxns = [a b];

        %view(-28,43);
        view(89,27);
        set(gca, 'xlim', [1 sz(1)], 'ylim', [1 sz(2)], 'zlim', [0 1]);
        set(gca, 'xtick', [], 'ytick', []);
        set(gca, 'ztick', [0 1], 'zticklabel', {'Input', 'Hidden'}, 'FontSize', 18);

        %Plot input/output layers
        [gX,gY] = meshgrid(1:gridfreq:sz(1), 1:gridfreq:sz(2)); % all inputs
        plot3(gX,gY, zeros(size(gX)),  'k.', 'MarkerSize', 0.5);  % input layer: 

        %inputs
        plot3(cxns(:,1), cxns(:,2), 0*ones(size(cxns(:,2))), 'bo','MarkerSize', 5, 'LineWidth', 5);

        % connect them
        for j=1:size(cxns,1), plot3([cxns(j,1) huloc(1)], [cxns(j,2), huloc(2)], [0 1], 'k'); end;

        % hidden unit
        plot3(huloc(1), huloc(2), 1,  'ro','MarkerSize', 10, 'LineWidth', 10)


        subplot(3,length(freqs), floor((length(freqs)-1)/2 +2));
        [xv] = histc(bestofall(1:sampnum),1:length(freqs));
        bar(xv/sum(xv));
        set(gca,'FontSize',14);
        set(gca,'xlim', [0 length(freqs)+1], 'ylim',[0 1.05]);
        set(gca, 'xtick', 1:length(freqs));
        set(gca,'xticklabel',guru_csprintf('F%d', num2cell(1:length(freqs))));
        title(sprintf('# samples: %d', sampnum), 'FontSize',18);


        for fi=1:length(freqs)

            % row 2: fi col [2,5,etc]
            subplot(3,length(freqs), length(freqs)+fi);
            imagesc(reshape(best_x(fi,:), sz), [0 1]);
            colormap gray;
            axis square; axis image;
            set(gca,'xtick',[],'ytick',[]);
            title(sprintf('F%d', fi), 'FontSize',18);

            % row 3: fi col [3,6,etc]
            subplot(3,length(freqs), 2*length(freqs)+fi);
            imagesc(reshape(best_x(fi,:),sz).*w, 0.01*[0 1]);
            colormap gray;
            axis square; axis image;
            set(gca,'xtick',[],'ytick',[]);

            if (bestofall(sampnum)==fi)
                opts = {'FontSize',16,'Color','r'};
            else
                opts = {'FontSize',16};
            end;
            resp = squeeze(resps(fi,:,:));
            mn   = mean(resp(:));
            rng  = max(resp(:)) - min(resp(:));
            %title(sprintf('best: %6.4f\nmean: %4.3e\nrange: %4.3e',
            %best_vals(fi), mn, rng), opts{:});
            xlabel(sprintf('sum: %6.4f', best_vals(fi)), opts{:});
        end;

        subplot(3,length(freqs), length(freqs)+1);
        ylabel('Best stimulus', 'FontSize',16);

        subplot(3,length(freqs), 2*length(freqs)+1);
        ylabel(sprintf('Weighted\nresponse'), 'FontSize',16);
        %if (bestofall(sampnum)~=1)
        %    drawnow;
        %end;
    end;
    drawnow;
end;
