function [data] = r_test(net,pats,data)
    axon_noise = net.sets.axon_noise;
    
    % No "lesion" case directly; must have 
    %   "test" patterns
    if (isfield(pats,'test'))
        pats_name = 'test';
    else
        pats_name = 'train';
    end;
                
    fprintf('Running %s patterns on lesioned vs non-lesioned network network\n', pats_name);
    net.sets.axon_noise = 0;
    data.nolesion = r_forwardpass(net,pats.(pats_name),data);
    data.nolesion.pats = pats_name;
    
    net.sets.axon_noise = axon_noise;
    data.noise = r_forwardpass(net, pats.(pats_name), data);  
        
    if net.ncc==0
        net           = r_lesion_cc(net);%, 'rh');
    else
        net           = r_lesion_cc(net);
    end;
        
    net.sets.axon_noise = 0;
    data.lesion   = r_forwardpass(net,pats.(pats_name),data);
    data.lesion.pats   = pats_name;
    
    net.sets.axon_noise = axon_noise;
    data.noisel = r_forwardpass(net, pats.(pats_name), data);  

