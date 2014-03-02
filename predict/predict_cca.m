function ccas = predict_cca(brwt,bvol)
    global g_cca;

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    
    if isempty(g_cca)
        pd_dir = fileparts(which(mfilename));

        % predict cat / lamantia
        addpath(fullfile(pd_dir, '..', '..', 'rilling_insel_1999a')); ria_data; close all;
        addpath(fullfile(pd_dir, '..', '..', 'rilling_insel_1999b')); rib_data; close all;
        
        [~,g_cca] = allometric_regress(rib_table1_brainvol, rib_table1_ccarea);
    end;
    
    ccas = g_cca.y(bvol);