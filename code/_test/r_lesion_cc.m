function [net] = r_lesion_cc(net)
%

    net.cC(net.idx.lh_cc,net.idx.rh_cc) = false;
    net.cC(net.idx.rh_cc,net.idx.lh_cc) = false;
    net.w = net.w.*net.cC;
