function ndens = predict_ndens(brwt,bvol)
%function ndens = predict_ndens(brwt,bvol)
%
% Predict the neuron density, based on data from Tower (1954)

    global g_ndens

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    
    if isempty(g_ndens)
        pd_dir = fileparts(which(mfilename));

        %addpath(fullfile(pd_dir, '..', '..', 'haug_1987'));   ha_data;  close all;
        %[~, g_ndens] = allometric_regression( ha_fig7_brain_volume, ha_fig7_neuron_density, 'log', 1, true );

        addpath(fullfile(pd_dir, '..', '..', 'tower_1954'));     tow_data; close all;
        [~, g_ndens] = allometric_regression( tow_fig1_brain_weight, tow_fig1_neuron_dens, 'log', 1, true, false);
    end;

    ndens = g_ndens.y(bvol);

