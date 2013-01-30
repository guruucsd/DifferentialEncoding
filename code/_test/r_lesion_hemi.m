function [net] = r_lesion_cc(net, hemi)
%
    net.cC(net.idx.([hemi '_cc']),:) = false;
    net.cC(net.idx.([hemi '_ih']),:) = false;
    net.w = net.w.*net.cC;
