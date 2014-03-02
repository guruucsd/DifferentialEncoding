function [dens] = predict_cc_density(brwt, bvol)
%

    global p_ccdens g_ccdens;

    % convert to native units
    if ~exist('brwt','var') || isempty(brwt), brwt = predict_bwt(bvol); end;

    if isempty(g_ccdens)
        %% Compare # neurons to # cc connections
        % Function for computing cc density from brain volume
        pd_dir = fileparts(which(mfilename));
        addpath(fullfile(pd_dir, '..', '..', 'wang_etal_2008')); w_data; close all;
        
        human_dens_ab_raw = 3.717*1E5*(1-0.35)^(1); %correct for shrinkage
        human_dens_ab   = human_dens_ab_raw*1.21;  %  correct for 20% missing fibers
        human_dens_abcor= human_dens_ab*1.2;       % correct for age

        [p_ccdens, g_ccdens] = allometric_regression( [w_fig1e_weights 1300], [w_fig1e_dens_est human_dens_abcor/1E6], 'log', 1, true, '3' );
    end;

    dens = g_ccdens.y(brwt);