function [f] = ringo_figures(net, pats, data)
    f = [];
    
    %%%%%%%%%%%%%%
    % Figures
    %%%%%%%%%%%%%%
    
    f(end+1) = figure;
    hold on;
    plot(mean(data.lesion.avgerr,2));
    plot(mean(data.nolesion.avgerr,2));
    
    %out.E_lesion - out.E_pat(100:100:end,:,:)