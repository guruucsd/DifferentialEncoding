function [data] = r_test(net,pats,data)

    % No "lesion" case directly; must have 
    %   "test" patterns
    if (isfield(pats,'test'))
        pats_name = 'test';
    else
        pats_name = 'train';
    end;
                
    fprintf('Running %s patterns on lesioned vs non-lesioned network network\n', pats_name);
    data.nolesion = r_forwardpass(net,pats.(pats_name),data);
    data.nolesion.pats = pats_name;
        
    if net.ncc==0
        net           = r_lesion_hemi(net, 'rh');
    else
        net           = r_lesion_cc(net);
    end;
        
    data.lesion   = r_forwardpass(net,pats.(pats_name),data);
    data.lesion.pats   = pats_name;
    
