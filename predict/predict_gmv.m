function [gmv,gma,gmt] = predict_gmv(brwt, bvol, collation)
%function [gmv,gma,gmt] = predict_gmv(brwt, bvol)
%
% Predict grey matter volume, based on GMA from rilling & insel, and 

    global g_gmv g_gma

    if ~exist('collation','var'), collation='individual'; end;
    
    if isempty(g_gmv)
        pd_dir = fileparts(which(mfilename));

        %
        addpath(fullfile(pd_dir, '..', '..', 'rilling_insel_1999a')); ria_data;
        addpath(fullfile(pd_dir, '..', '..', 'rilling_insel_1999b')); rib_data;

        %%
        [~,famidxa] = ismember(ria_table1_families, rib_families);
        [~,famidxb] = ismember(rib_fig1b_families, rib_families);
        families      = unique(famidxb);
        nfamilies     = length(families);

        switch collation
            case {'family' 'family-i'} % from individual
                [~,famidxa] = ismember(ria_table1_families, rib_families);
                [~,famidxb] = ismember(rib_fig1b_families, rib_families);
                unfamidx      = unique(famidxb);
                nfamilies     = length(families);
                bvols = zeros(nfamilies, 1);%size(famidxb));
                ccas = zeros(nfamilies, 1);
                gmas = zeros(nfamilies, 1);
                for fi=families
                    idxa = fi==famidxa;
                    idxb = fi==famidxb;
                    bvols(fi) = mean(rib_fig1b_brain_volumes(idxb));
                    ccas(fi) = mean(rib_fig2_ccas(idxb));
                    gmas(fi) = mean(rib_fig2_gmas(idxb)).*mean(ria_table6_gi(idxa));
                end;

            case 'family-s' %from species
                error('must account for GI');
                bvols = zeros(size(nfamilies, 1));
                ccas = zeros(size(nfamilies, 1));
                gmas = zeros(size(nfamilies, 1));
                for fi=families
                    fidx = ria_fam_idx==unfamidx(fi);
                    bvols(fi) = mean(ria_table1_brainvol(fidx));
                    ccas(fi) = mean(rib_table1_ccarea(fidx));
                    gmas(fi) = mean(ria_table1_gmvol(fidx)./predict_gm_thickness([], fi));
                end;

            case 'species'
                bvols = rib_table1_brainvol;%rib_fig1b_brain_volumes;
                ccas = rib_table1_ccarea;%rib_fig2_ccas;
                gmas = ria_table1_gmvol./predict_gm_thickness([], bvols);

            case 'individual'
                bvols = rib_fig1b_brain_volumes;
                ccas = rib_fig2_ccas;

                % Use the family GI
                gis  = zeros(size(rib_fig2_gmas));
                for fi=families
                    gis(famidxb==fi) = mean(ria_table6_gi(famidxa==fi));
                end;

                gmas = rib_fig2_gmas.*gis;
        end;
        
        % Now, do the regressions
        gmts = predict_gm_thickness([], bvol);
        [~,g_gma] = allometric_regression(bvols, gmas);
        [~,g_gmv] = allometric_regression(bvols, gmas.*gmts);
    end;
    
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;

    % Now use the functions to compute # cc fibers and # neurons
    gmt = predict_gm_thickness(brwt, bvol);
    gma = g_gma.y(bvol);
    gmv = g_gmv.y(bvol);
    
