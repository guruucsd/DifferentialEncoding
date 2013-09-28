% I believe this essentially duplicates demo_2layer

clear all; %close all;
addpath(genpath('../../code'))

sz = [20 20];
nbatches = 10;
nsamps = 5;
mode = 'max';
%thresh
nout = round( prod(sz) * (0/100) );

nphases = 8;
norients=8;
freqs = 0.01 * [ 6 8 10 12];

mu = 10+ [0 0]; 
Sigma = 50*eye(2);
[X1,X2] = meshgrid([1:sz(1)]', [1:sz(2)]');
X = [X1(:) X2(:)];

figure; 
set(gcf,'Position',[ 84         -21        1014         705]);
bestofall=[];

resps = zeros(length(freqs),norients,nphases);


for jj = 1:nbatches
    for ii=1:nsamps
        w = reshape( mvnpdf(X, mu, Sigma), sz);
        %w = (w>0.002);

        outidx = randperm(numel(w));
        w(outidx(1:nout)) = 0;
        %w = w / sum(w(:));


        %surf(X1,X2,reshape(p,sz));


        best_vals = -inf*ones(size(freqs));
        best_params = zeros(length(freqs), 3);
        best_x = zeros(length(freqs), prod(sz));

        for fi=1:length(freqs)
            ci = 1;
            
            % Find the best fit orientation and phase
            for oi = 1:norients
                orient = 2*pi*oi/8;
                for phsi=1:nphases
                    phase = 2*pi*phsi/4;

                    x = 0.5+mfe_grating2d( freqs(fi), phase, orient, 0.5, sz(1), sz(2));
                    resps(fi,oi,phsi) = sum(x(:).*w(:));
                    
                    if (best_vals(fi)<resps(fi,oi,phsi))
                        best_vals(fi)     = sum(x(:).*w(:));
                        best_params(fi,:) = [freqs(fi) orient phase];
                        best_x(fi,:)      = x(:);
                    end;
                    ci = ci + 1;
                end;
            end;
        end;

        switch mode
            case 'max',   [~,bestofall(end+1)] = max(best_vals);
            case {'mean','total'}                                                                                                        , [~,bestofall(end+1)] = max(mean(mean(resps,3),2));
            case 'range', 
                alld = reshape(resps, [length(freqs), norients*nphases]);
                rng  = max(alld') - min(alld');
                [~,bestofall(end+1)] = max(rng);
        end;

        % row 1, center col: receptive field weights
        subplot(3,length(freqs), floor((length(freqs)-1)/2 +1));
        imagesc(w);
        colormap gray;
        axis square; axis image;
        set(gca,'xtick',[],'ytick',[]);
        title('Weights', 'FontSize',18);

        subplot(3,length(freqs), length(freqs)-1);
        [xv] = histc(bestofall,1:length(freqs));
        bar(xv/sum(xv));
        set(gca,'ylim',[0 1]);
        title(sprintf('# samples: %d', length(bestofall)), 'FontSize',18);


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

            if (bestofall(end)==fi)
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
        if (bestofall(end)~=1)
            drawnow;
            %keyboard
        end;
    end;
    drawnow;
end;
