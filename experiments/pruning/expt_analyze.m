function expt_analyze(models, wss, s, exts, force)
    cur_dir = fileparts(which(mfilename));
    addpath(genpath(fullfile(cur_dir, '..', '..', 'code', 'analyze', 'ac', 'stats')));

    if ~exist('exts','var'), exts = {'png'}; end;
    if ~exist('force', 'var'), force = false; end;
    ws = wss{1}(1);

    % Collect basic stats
    [s.basics] = expt_basics( models, ws, s );

    % Collect histogram stats
    [s.hist, f.hist] = expt_histograms( models, ws, s );
    if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    saveas_multiformat(f.hist, fullfile(ws.plotdir, 'f_hist'), exts);

    % Collect distribution stats
    s.distn = de_StatsDistributions(models);
    f.distn = de_PlotDistributions(models{end}(end), s.distn);
    if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    for ii=1:length(f.distn)
        saveas_multiformat(f.distn(ii).handle, fullfile(ws.plotdir, ['f_distn_' f.distn(ii).name]), exts);
    end;


    % Collect inter-patch distance stats
    [s.ipd,  f.ipd ] = expt_ipd( models, ws );
    if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    for ii=1:length(f.ipd)
        saveas_multiformat(f.ipd(ii).handle, fullfile(ws.plotdir, ['f_ipd_' f.ipd(ii).name]), exts);
    end;

    % Collect stats on shapes
    %if force || (~exist(ws.plotdir,'dir') || length(dir(fullfile(ws.plotdir,'f_shape_*.png')))==0)
    %  [s.shp,  f.shp ] = expt_shapes( models, ws, s.ipd );
    %  if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    %  saveas_multiformat(f.shp,  fullfile(ws.plotdir, 'f_shape_map'), exts);
    %end;

    % Collect spatial frequency info
    if (~exist(ws.plotdir,'dir') || length(dir(fullfile(ws.plotdir,'f_sf_*.png')))==0)
      [s.sf,  f.sf ] = expt_sf( models, wss );
      if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
      for ii=1:length(f.sf)
        saveas_multiformat(f.sf(ii).handle, fullfile(ws.plotdir, ['f_sf_' f.sf(ii).name]), exts);
      end;
    end;

    % Collect
    %if force || (~exist(ws.plotdir,'dir') || length(dir(fullfile(ws.plotdir,'f_trn_*.png')))==0)
    %  [s.trn,  f.trn ] = expt_trn( models, ws );
    %  if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    %  for ii=1:length(f.trn)
    %    saveas_multiformat(f.trn(ii).handle, fullfile(ws.plotdir, ['f_trn_' f.sf(ii).name]), exts);
    %  end;
    %end;

    %[s.cxn,  f.cxn ] = expt_connections( models, ws, s.shp );
    %if (~exist(ws.plotdir,'dir')), guru_mkdir(ws.plotdir); end;
    %saveas(f.cxn,  fullfile(ws.plotdir, 'f4'), exts);

    %[s.tst, f.tst] = expt_testsets( models, ws );
    %[s.cls,  f.cls ] = expt_classify( models, ws );


function saveas_multiformat(h, fn, exts)
    if ischar(exts), exts = {exts}; end;

    for ei = 1:length(exts)
        ext = exts{ei};
        saveas(h, [fn '.' ext], ext)
    end;

%%%%%%%%%%%%%%%%%%%%%%
function [s] = expt_basics( models, ws, s )
    mSets = models{end}(end);

    % Print summary
    fprintf('Trained on kernels [ %s] %d times each; nCs=%2d, nCe=%2d, sig=%3.1f, hpl=%d, lambda=%3.2f\n', ...
            [ws.klabs{:}], ws.N, ...
            mSets.nConnPerHidden_Start, mSets.nConnPerHidden_End, mSets.sigma, ...
            mSets.hpl, mSets.lambda);

    % Training time and error
    fprintf('\tavg iterations: [');
    for ii=1:length(models)
        iters = vertcat(models{ii}.Iterations);
        fprintf(' %4.1f', mean(iters(:)));
    end;
    fprintf(']\n');

    for ii=1:length(models)
        fprintf('\tavg errors: [\t');
        avgerr = vertcat(models{ii}.avgErr);
        fprintf(' %4.2e', mean(avgerr,1));
        fprintf(']\n');
    end;



%%%%%%%%%%%%%%%%%%%%%%
function [s,f] = expt_histograms( models, ws, s_in )

    % Plot them
    s.nbins   = 20;

    % Collect histogram stats
    s.dof = cell(ws.nkernels,1);    % raw data for original connection inter-patch distances
    s.def = cell(ws.nkernels,1);    % raw data for end-state connection inter-patch distances
    s.d_o = cell(ws.nkernels,1);    % histogram of original connection inter-patch distances
    s.d_e = cell(ws.nkernels,1);    % histogram of end-state connection inter-patch distances
    s.d_f = cell(ws.nkernels,1);    % difference between histograms
    for fi=1:ws.nkernels
        s.dof{fi}      = vertcat(s_in.dist_orig_full{fi,:});   % one big data vector (cxn distances before pruning)
        [s.d_o{fi},xn] = hist(s.dof{fi}, s.nbins);            % histogram
        s.d_o{fi}      = s.d_o{fi} ./ sum(s.d_o{fi});         % normalize

        if (fi==1), s.bins = xn; end; %store the initial value, for reuse

        s.def{fi} = vertcat(s_in.dist_end_full{fi,:});         % one big data vector (cxn distances after pruning)
        s.d_e{fi} = hist(s.def{fi}, s.bins);                 % histogram
        s.d_e{fi} = s.d_e{fi} ./ sum(s.d_e{fi});              % normalize

        s.d_f{fi} = s.d_e{fi} - s.d_o{fi};
    end;

    % Plot the histograms
    yl_abs  = [0.9 1.1] .* [min(horzcat(s.d_e{:}, s.d_o{:})) max(horzcat(s.d_e{:}, s.d_o{:}))];
    yl_diff = [0.9 1.1] .* [min(0,min(horzcat(s.d_f{:})))    max(0.01,max(horzcat(s.d_f{:})))];

    f = figure;
    for fi=1:ws.nkernels
        % Histograms figure
        figure(f);
        subplot(ws.nkernels+1,3,3*(fi-1)+1);
        bar(s.bins,s.d_o{fi}); set(gca,'ylim',yl_abs);
        title(sprintf('Orig: mn=%4.2f,md=%4.2f,std=%4.2f', ...
                      mean(s.dof{fi}), median(s.dof{fi}), std(s.dof{fi}) ));

        subplot(ws.nkernels+1,3,3*(fi-1)+2);
        bar(s.bins,s.d_e{fi}); set(gca,'ylim',yl_abs);
        title(sprintf('[%s]: mn=%4.2f,md=%4.2f,std=%4.2f', ...
                      ws.klabs{fi}, mean(s.def{fi}), median(s.def{fi}), std(s.def{fi}) ));

        subplot(ws.nkernels+1,3,3*(fi-1)+3);
        bar(s.bins, s.d_f{fi} ); set(gca, 'ylim', yl_diff);
        title('Pruning Accentuates [dist from center]:');
    end;

    % Show the difference between LH and RH differences
    subplot(ws.nkernels+1,3,3*(ws.nkernels+1) + [-1 0]); % last row of three
    bar(s.bins, s.d_f{end}-s.d_f{1});
save

%%%%%%%%%%%%%%%%%%%%%%
function [ipd, fs] = expt_ipd( models, ws )
    mSets = models{end}(end);

    % 5. Inter-patch distance
    ipd = de_StatsInterpatchDistance(models);
    if (ismember(10, mSets.debug)), ipd, end;
    fprintf('[Total  ]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
            100*diff(ipd.nearest_neighbor_mean)      /mean(ipd.nearest_neighbor_mean), ...
            100*diff(ipd.from_center_mean)           /mean(ipd.from_center_mean));
    fprintf('[Top  5%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
            100*diff(ipd.top5.nearest_neighbor_mean) /mean(ipd.top5.nearest_neighbor_mean), ...
            100*diff(ipd.top5.from_center_mean)      /mean(ipd.top5.from_center_mean));
    fprintf('[Top 10%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
            100*diff(ipd.top10.nearest_neighbor_mean)/mean(ipd.top10.nearest_neighbor_mean), ...
            100*diff(ipd.top10.from_center_mean)     /mean(ipd.top10.from_center_mean));
    fprintf('[Top 25%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
            100*diff(ipd.top25.nearest_neighbor_mean)/mean(ipd.top25.nearest_neighbor_mean), ...
            100*diff(ipd.top25.from_center_mean)     /mean(ipd.top25.from_center_mean));


    if (true || ws.nkernels~=2)
        f = [];
        ipd = [];
        fs = [];

    else
        % Similar map, showing difference in mean ipd
        nn_mns = zeros(length(ipd.neighbor_dists),size(ipd.neighbor_dists{1},2));
        fc_mns = zeros(length(ipd.fc_dists),size(ipd.fc_dists{1},2));
        for fi=1:size(nn_mns,1)      % kernels
            for hui=1:size(nn_mns,2)  % hidden units
                nn_mns(fi,hui) = mean( horzcat(ipd.neighbor_dists{fi}{:,hui}) ); % average over model instances
                fc_mns(fi,hui) = mean( horzcat(ipd.fc_dists{fi}{:,hui}) );
            end;
        end;

        nPos      = mSets.nHidden/mSets.hpl;
        [~,mupos] = de_connector_positions(mSets.nInput, nPos);
        mupos = round(mupos);

        nn_dff = diff(nn_mns,1);
        fc_dff = diff(fc_mns,1);

        nn_img = zeros(mSets.nInput);
        fc_img = zeros(mSets.nInput);
        for mi=1:size(mupos,1)
            huis = mi:nPos:mSets.nHidden;

            nn_img(mupos(mi,1),mupos(mi,2)) = mean(nn_dff(huis));             % Average over all hidden units at this position
            fc_img(mupos(mi,1),mupos(mi,2)) = mean(fc_dff(huis));
        end;


        fs(1).handle = figure;
        fs(1).name   = 'by_hu_position';
        colormap jet;

        subplot(1,2,1);
        cl_nn = [-max(0.1,max(abs(nn_dff))) max(0.1,max(abs(nn_dff)))];
        imagesc(nn_img, cl_nn); axis image;
        set(gca, 'xtick', [], 'ytick', []);
        colorbar;
        title('Diff in mean of [min patch distance]');
        xlabel(sprintf('Positive=>%s > %s', ws.klabs{2}, ws.klabs{1}));

        subplot(1,2,2);
        cl_fc = [-max(0.1,max(abs(fc_dff))) max(0.1,max(abs(fc_dff)))];
        imagesc(fc_img, cl_fc); axis image;
        set(gca, 'xtick', [], 'ytick', []);
        colorbar;
        title('Diff in mean of [distance from center]');
        xlabel(sprintf('Positive=>%s > %s', ws.klabs{2}, ws.klabs{1}));


        % Get histograms
        nkernels  = length(ipd.neighbor_dists);
        ipd.nbins =20;
        ipd.bins  = [linspace(1,10,20)];
        ipd_hists = zeros(nkernels,ipd.nbins);

        for fi=1:nkernels
            d = horzcat(ipd.neighbor_dists{fi}{:});

            if (isfield(ipd,'bins'))
                ipd_hists(fi,:) = hist(d, ipd.bins)/length(d);
            else
                [ipd_hists(fi,:),ipd.bins] = hist(d, ipd.nbins)/length(d);
            end;
        end;

        fs(2).handle = figure;
        fs(2).name   = 'hist';
        colormap jet;

        yl = [0 .5];
        xl = [ipd.bins(1)-0.5 ipd.bins(end)+0.5];
        for fi=1:nkernels
            subplot(1,nkernels+1,fi);
            bar(ipd.bins,ipd_hists(fi,:));
            set(gca,'ylim',yl,'xlim',xl);
            xlabel('inter-patch distance');
            ylabel('proportion cxns');
            title(sprintf('k(%d)',fi));
        end;

        subplot(1,nkernels+1,nkernels+1);
        bar(ipd.bins,ipd_hists(end,:)-ipd_hists(1,:));
        set(gca,'xlim',xl);
        xlabel('inter-patch distance');
        ylabel('proportion cxns');
        title('diff [k(end) - k(1)]');

    end;


%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_shapes( models, ws, ipd )
    mSets = models{end}(end);

    % 6. Orientation of inter-connected patches
    inPix             = prod(mSets.nInput);
    [~,mupos]         = de_connector_positions(mSets.nInput, mSets.nHidden/mSets.hpl);
    s.dfc             = sqrt( sum((mupos - repmat(mSets.nInput/2, [size(mupos,1) 1])).^2, 2) ); % distance from center
    [~,s.closest_idx] = sort(s.dfc); %distance of each hu pos from center

    % Choose some hidden units
    s.chosen_idx = 1:size(mupos,1); %indices of units to consider (inside closest_idx)
    s.allpts     = cell(length(models), length(s.chosen_idx));
    %s.dists      = cell(length(models), length(s.chosen_idx));
    s.r          = cell(length(models), length(s.chosen_idx));
    s.rho        = cell(length(models), length(s.chosen_idx));
    s.pc         = cell(length(models), length(s.chosen_idx));
    s.pos        = cell(length(models), length(s.chosen_idx));
    s.dirsel     = cell(length(models), 1);
    s.radsel     = cell(length(models), 1);
    s.dblsel     = cell(length(models), 1);
    s.ra         = zeros(size(s.r));
    s.rhoa       = zeros(size(s.rho));

    for kki=1:length(models)
        for ci=1:length(s.chosen_idx)
            hui = s.closest_idx(s.chosen_idx(ci));

            % Collect the relevant data
            %s.dists{kki,ci}    = ipd.neighbor_dists{kki}(:,hui);
            s.allpts{kki,ci}   = zeros(0,2);
            s.r{kki,ci}        = zeros(0,1);
            s.rho{kki,ci}      = zeros(0,1);
            s.pc{kki,ci}       = zeros(0,2);
            s.pos{kki,ci}      = zeros(0,2);

            for mmi=1:length(models{kki})
                m   = models{kki}(mmi);

                % Collect all connections for all hidden units
                %   at this selected position
                hus = hui:(mSets.nHidden/mSets.hpl):m.nHidden;
                cc  = full(m.ac.Conn(inPix+1+hus, 1:inPix));
                pts = zeros(0,2);
                for xxi=1:size(cc,1) %each hidden unit
                    [cy,cx] = find(reshape(cc(xxi,:), m.nInput));
                    pts(end+1:end+length(cy), :) = [cy cx];
                    mi = mod(hus(xxi)-1, mSets.nHidden/mSets.hpl)+1;
                    s.pos{kki,ci}(end+1,:) = mupos(mi,:);
                end;

                if (isempty(pts)), continue; end;

                s.allpts{kki,ci}(end+1:end+size(pts,1), :) = pts;

                % Do PCA to find orientation of best-fitting ellipse,
                %   for all connections to a hidden unit POSITION
                %   (if hpl>1, then this means hpl hidden units worth of cxns
                z        = pts - repmat(mean(pts), size(pts,1), 1);
                [Vf,Df]  = eig(z'*z);
                Df       = sqrt(diag(Df));
                [Df,idx] = sort(Df,'descend');
                Vf       = Vf(:,idx);

                % Calculate relative size of axes and rotation of ellipse
                s.r{kki,ci}(end+1)    = Df(1)/Df(2);
                s.rho{kki,ci}(end+1)  = atan(Vf(2,1)/Vf(1,1));
                s.pc{kki,ci}(end+1,:) = Df;
            end;

            % NOTE: pca for ALL points (across all hidden units with
            %   same mupos (across layers & model instances))
            %   BUT, removing duplicate points (so to avoid weighting)
            %allpts{kki,ci} = unique(allpts{kki,ci},'rows');

            % Now do PCA on all connections (all model instances & layers)
            z        = s.allpts{kki,ci} - repmat(mean(s.allpts{kki,ci}), size(s.allpts{kki,ci},1), 1);
            [Vf,Df]  = eig(z'*z);
            Df       = sqrt(diag(Df))/3;
            [Df,idx] = sort(Df,'descend');
            Vf       = Vf(:,idx);

            % Calculate relative size of axes and rotation of ellipse
            s.ra(kki,ci)   = Df(1)/Df(2);
            s.rhoa(kki,ci) = atan(Vf(2,1)/Vf(1,1));


            % Find the best way to describe the direction selectivity data
            rho2 = (s.rho{kki,ci}>=0).*s.rho{kki,ci} + (s.rho{kki,ci}<0).*(pi+s.rho{kki,ci});
            if (std(s.rho{kki,ci})>std(rho2)), s.rho{kki,ci} = rho2 - pi/2; end;
            guru_assert(~any(abs(s.rho{kki,ci}) > pi/2)); %programming check

            %fprintf('[%2d]: d=%5.2e; r = %4.3f+/-%4.3f, rho=%4.3f +/- %4.3f [%u]\n', ...
            %        ci, dfc(hui), ...
            %        mean(r{kki,ci}),   std(r{kki,ci}), ...
            %        mean(rho{kki,ci}), std(rho{kki,ci}), ...
            %        any(rho2-rho{kki,ci}));

             % If it looks like we have direction selectivity, then show me!
             if (std(s.rho{kki,ci})<pi/length(s.rho{kki,ci}))
                 s.dirsel{kki}(end+1) = ci;
             end;

             % If it looks like we have good radial selectivity, then show me!
             cap_r = min(5,s.r{kki,ci});
             if (mean(cap_r)>=1.5 && (mean(cap_r) - 2*std(cap_r))>=2)
                 s.radsel{kki}(end+1) = ci;
%
%                 if (~isempty(dirsel{kki}) && dirsel{kki}(end)==ci)
%                     dblsel{kki}(end+1) = ci;
%                     radsel{kki} = radsel{kki}(1:end-1);
%                     dirsel{kki} = dirsel{kki}(1:end-1);
%                 end;
             end;

             % If it looks like we have direction selectivity, then show me!
             if (s.ra(kki,ci)>4)
                 s.dblsel{kki}(end+1) = ci;
             end;
        end; % for selected units
    end; % for models

    % Now, report on the data we just collected
    s.huis   = s.closest_idx(s.chosen_idx);

    for kki=1:size(s.dblsel,1)
        fprintf('[%2d]: Good DOUBLE      selectivity: %3d]\n', kki, length(s.dblsel{kki}));
        if (ismember(11, mSets.debug))
            for xxi=1:length(s.dblsel{kki})
                ci = s.dblsel{kki}(xxi);
                fprintf('\t[%4d]: @ %5.1f [ %s] \\\\ // [ %s]\n', s.huis(ci), s.dfc(s.closest_idx(s.chosen_idx(ci))), ...
                        sprintf('%4.2f ', s.r{kki,ci}), ...
                        sprintf('%4.2f ', s.rho{kki,ci}));
            end;
        end;
    end;
    for kki=1:size(s.dirsel,1)
        fprintf('[%2d]: Good DIRECTIONAL selectivity: %3d]\n', kki, length(s.dirsel{kki}));
        if (ismember(11, mSets.debug))
            for xxi=1:length(s.dirsel{kki})
                ci = s.dirsel{kki}(xxi);
                fprintf('\t[%4d]: @ %5.1f [%4.3f+/-%4.3f] : [ %s] \\\\ // [ %s]\n', ...
                        s.huis(ci), s.dfc(s.closest_idx(s.chosen_idx(ci))), ...
                        mean(s.r{kki,ci}), std(s.r{kki,ci}), ...
                        sprintf('%4.2f ', s.r{kki,ci}), ...
                        sprintf('%4.2f ', s.rho{kki,ci}));
            end;
        end;
    end;
    for kki=1:size(s.radsel,1)
        fprintf('[%2d]: Good RADIAL      selectivity: %3d]\n', kki, length(s.radsel{kki}));
        if (ismember(11, mSets.debug))
            for xxi=1:length(s.radsel{kki})
                ci = s.radsel{kki}(xxi);
                fprintf('\t[%4d]: @ %5.1f [%4.3f+/-%4.3f] : [ %s] \\\\ // [ %s]\n', ...
                     s.huis(ci), s.dfc(s.closest_idx(s.chosen_idx(ci))), ...
                     mean(s.rho{kki,ci}), std(s.rho{kki,ci}), ...
                     sprintf('%4.2f ', s.r{kki,ci}), ...
                     sprintf('%4.2f ', s.rho{kki,ci}));
            end;
        end;
    end;

    % Now plot maps of original, low, & high
    f = figure;
    for ii=1:3
        switch (ii)
            case 1, d = s.dirsel; tit = 'Elongated';
            case 2, d = s.radsel; tit = 'Oriented';
            case 3, d = s.dblsel; tit = 'Elongated AND Oriented';
        end;

        for spi=1:1+size(d,1)
            subplot(3,1+size(d,1), (ii-1)*(1+size(d,1))+spi)

            img = zeros(mSets.nInput);
            if (spi==1)
            else
                for jj=1:length(d{spi-1})
                    hupos = round(s.pos{1,d{spi-1}(jj)}(1,:));
                    img(hupos(:,1),hupos(:,2)) = 1;
                end;
                guru_assert( nnz(img) == length(d{spi-1}) );
            end;

            colormap(gray(256));
            imagesc(img); axis image;
            set(gca, 'xtick', [], 'ytick', []);
            if (spi==1), title(tit);
            else,        title(sprintf('[%s]: %s', ws.klabs{spi-1}, tit)); end;
        end;
    end;

%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_connections( models, ws, s_in )
    m = models{end}(end);
    mSets = m;
    inPix             = prod(mSets.nInput);


    % Validate that input & output connections are the same
    cc_in  = full(m.ac.Conn(inPix+1+[1:m.nHidden], 1:inPix)); % input=> hidden
    cc_out = full(m.ac.Conn(inPix+1+m.nHidden+[1:inPix], inPix+1+[1:m.nHidden])); %hidden=>output
    guru_assert(~any(diff(sum(cc_in,2)' - sum(cc_out,1)))); % make sure they're the same

    % Find directionally selective (~=0) inter-patch networks
    s.dsis = cell(size(s_in.dblsel)); %doubly-selective: elongated and oriented
    nsp = 0;
    for kki=1:length(s_in.dblsel)
        mns = zeros(length(s_in.chosen_idx),1);
        for ci=1:length(mns), s.mns(ci) = mean(s_in.rho{kki,ci}); end;
        s.dsis{kki} = intersect(s_in.dblsel{kki}, find(abs(s.mns)>pi/8));
        if (length(s.dsis{kki})>nsp), nsp = length(s.dsis{kki}); end;
    end;

    f = figure;
    for kki=1:length(s_in.dblsel)
        cxns = zeros(mSets.nHidden, inPix);
        for mmi = 1:length(models{kki})
            cxns = cxns + models{kki}(mmi).ac.Conn(inPix+1+[1:mSets.nHidden], 1:inPix);
        end;
        break;
        for ci = 1:length(s.dsis{kki})
            subplot(length(s_in.dblsel), nsp, (kki-1)*nsp+ci);
            img = zeros(mSets.nInput);
            img(find(cxns(s_in.huis(ci), :))) = 1;

            colormap(gray(256));
            imagesc(img); axis image;
            set(gca, 'xtick', [], 'ytick', []);
        end;
    end;



%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_images( models, ws )

%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_sf( models, wss )
%
% Analyze spatial frequency content when we run different types of images through.
%
% NOTE: even though the networks were trained on different kernels,
%   they are tested on images with the same kernel here.
%
    if (~exist('kernel','var')),   kernel = 0; end; %blurring kernel for test images
    if (~exist('testsets','var')), testsets = {'natimg','sergent','cafe'}; end;

    f = de_NewFig('dummy');

    %
    ws = wss{1}(1);
    ws.kernels(end) = kernel;

    %
    mSets    = models{end}(end);
    for ii=1:length(models), mSets.sigma(ii) = models{ii}(1).sigma; end;

    %
    for ti=1:length(testsets)
        fprintf('\nTesting datset %s on kernel[%dpx]:\n', testsets{ti}, kernel);
        figs = de_NewFig('dummy');
        ws.dataset_train.name = testsets{ti}; ws.dataset_test.name = testsets{ti};%ws.dataset_train;
        [train, test] = create_dataset(ws, mSets, ws.nloops); % use the final

        % Save the reconstructed images and frequency stats
        %
        %  NOTE: the models must be reversed.  Or... should they?  lol...
        %    [RH LH]... and we have [lsf hsf]... so ... no reversal, right?
        %
        s.(testsets{ti}).rimgs = cell(size(wss));
        %selimg = round(linspace(1,size(test.X,2),16));
        for ri=1:length(wss)
            s.(testsets{ti}).rimgs(ri) = de_StatsOutputImages(models(ri), test, 1:size(test.X,2));
            figs = [figs de_PlotOutputImages(mSets, s.(testsets{ti}).rimgs{ri}, test.XLAB)];
        end;
        s.(testsets{ti}).orig  = de_StatsFFTs( test, test.X(1:ws.inPix,:));  % original images
        s.(testsets{ti}).model = de_StatsFFTs( test, s.(testsets{ti}).rimgs );
        s.(testsets{ti}).pals  = de_StatsFFTs_TTest( s.(testsets{ti}) );

        % Plot the results
        figs = [figs de_PlotFFTs(mSets, s.(testsets{ti}))];
        for ii=1:length(figs) % rename figures so that figures across different datasets have differen tnames
            figs(ii).name = sprintf('%s[%dpx]-%s', testsets{ti}, kernel, figs(ii).name);
        end;
        f = [f figs];
    end;

%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_trn( models, ws, kernel )
%
% Analyze spatial frequency content AFTER FURTHER TRAINING ON HSF IMAGES! :D
%
% NOTE: even though the networks were trained on different kernels,
%   they are tested on images with the same kernel here.
%

    % Do final leg of training, but this time on
    %   non-blurred images

    if (~exist('kernel','var')), kernel = 1; end; %blurring kernel for test images

    f = zeros(size(ws.fullfidel.X));
    G = fspecial('gaussian', [kernel kernel], 4);
    for ii=1:size(f,2)
        fc      = reshape(ws.fullfidel.X(:,ii), ws.fullfidel.nInput);
        fc      = imfilter(fc,G,'same');
        f(:,ii) = reshape(fc, size(f(:,ii)));
    end;

    for ki=1:length(models)
        mss=cell(size(models{ki}));
        parfor mi=1:length(models{ki})
            model = models{ki}(mi);
            model.Conn = model.ac.Conn;
            model.Weights = model.ac.Weights;

            %guru_assert(isfield(model,'absmean'));
            %guru_assert(isfield(model,'minmax'));

            dset                = de_NormalizeDataset(struct('X', f), struct('ac',models{1}(1)));
            X                   = dset.X;               % Input vectors;  [pixels examples]
            X(end,:)            = dset.bias;            % Keep same bias value
            Y                   = dset.X(1:end-1,:);    % everything but the bias
            %dset = []; % parfor 'clear'

            mss{mi}             = guru_nnTrain(model, X, Y); %structure changes... so need to roll with that!
        end;
        models{ki} = [ mss{:} ];
    end;


    % Save the reconstructed images and frequency stats
    %
    %  NOTE: the models must be reversed.  Or... should they?  lol...
    %    [RH LH]... and we have [lsf hsf]... so ... no reversal, right?
    %
    s.rimgs = de_StatsOutputImages(models, de_NormalizeDataset(ws.test, struct('ac',models{1}(1))), 1:size(ws.test.X,2));
    s.orig  = de_StatsFFTs( ws.test, ws.test.X);  % original images
    s.model = de_StatsFFTs( ws.test, s.rimgs );
    s.pals  = de_StatsFFTs_TTest( s );

    % Plot the results
    f = de_PlotFFTs(mSets, s);
    for ii=1:length(f)
        f(ii).name = sprintf('%s[%dpx]-%s', testsets{ti}, kernel, f_new(ii).name);
    end;


%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_classify( models, ws )

%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_zoom( models, ws )
    mSets = models{end}(end);
    inPix             = prod(mSets.nInput);

    dzf = figure;
    nsp = 2;
    for kki=1:length(s.dblsel)
        cxns = zeros(mSets.nHidden, inPix);
        for mmi = 1:length(models{kki})
            cxns = cxns + models{kki}(mmi).ac.Conn(inPix+1+[1:nHidden], 1:inPix);
        end;
        for ci = 1:min(nsp,length(dblsel{kki}))
            subplot(length(dblsel), nsp, (kki-1)*nsp+ci);
            img = reshape( cxns(s_in.huis(dblsel{kki}(end+1-ci)),:), mSets.nInput );
            [cy,cx] = find(img);
            img = img(min(cy):max(cy), min(cx):max(cx));
            colormap(jet);
            imagesc(img); axis image;
            set(gca, 'xtick', [], 'ytick', []);
        end;
    end;



%%%%%%%%%%%%%%%%%%%%%%
function [s, f] = expt_junk( models, ws )
%    figure;
%    subplot(1,1+size(dblsel,1), 1)
%    for spi=1:1+size(dblsel,1)
%        subplot(1,1+size(dblsel,1), spi)
%        img = zeros(mSets.nInput);
%
%        if (spi==1)
%            hui = closest_idx(chosen_idx);%1:size(mupos,1);
%            for xxi=1:length(hui), img(mupos(hui(xxi),1), mupos(hui(xxi),2)) = 1; end;
%        else
%            hui = closest_idx(chosen_idx(dblsel{spi-1}));
%            for xxi=1:length(hui), img(mupos(hui(xxi),1), mupos(hui(xxi),2)) = mean(rho{spi-1, dblsel{spi-1}(xxi)}); end;
%        end;
%
%        guru_assert( nnz(img) == length(hui) );
%
%        colormap(jet);
%        imagesc(img); axis image;
%        set(gca, 'xtick', [], 'ytick', []);
%    end;
%    if (~exist(pngdir,'dir')), guru_mkdir(pngdir); end;
%    saveas_multiformat(gcf, '~/test-rho-q','png');

    % 7: Histogram of # of connections
%    cc_in  = full(m.ac.Conn(inPix+1+[1:m.nHidden], 1:inPix));
%    cc_out = full(m.ac.Conn(inPix+1+m.nHidden+[1:inPix], inPix+1+[1:m.nHidden]));
%    guru_assert(~any(diff(sum(cc_in,2)' - sum(cc_out,1))));
%    mean(sum(cc,2)');
