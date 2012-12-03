function [data] = r_test(net,pats,data)

    % No "lesion" case directly; must have 
    %   "test" patterns
    if (net.ncc == 0) 
        fprintf('Running training vs. test patterns (ncc=0)\n');
        data.nolesion = r_forwardpass(net,pats.train,data);
        data.nolesion.pats = 'train';
        
        data.lesion   = r_forwardpass(net,pats.test,data);
        data.lesion.pats   = 'test';
    
    elseif (isfield(pats,'test'))
        fprintf('Running test patterns on lesioned vs non-lesioned network network\n');
        data.nolesion = r_forwardpass(net,pats.test,data);
        data.nolesion.pats = 'test';
        
        net           = r_lesion_cc(net);
        data.lesion   = r_forwardpass(net,pats.test,data);
        data.lesion.pats   = 'test';
    
    else
        fprintf('Running training patterns on lesioned vs non-lesioned network network\n');
        data.nolesion = r_forwardpass(net,pats.train,data);
        data.nolesion.pats = 'train';
        
        net           = r_lesion_cc(net);
        data.lesion   = r_forwardpass(net,pats.train,data);
        data.lesion.pats   = 'train';
    end;
    
