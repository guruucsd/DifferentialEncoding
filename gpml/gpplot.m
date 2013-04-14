function gpplot(z,m,s2,x,y)
% Plot gaussian process    
    set(gca, 'FontSize', 24)
    f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
    fill([z; flipdim(z,1)], f, [7 7 7]/8);
    hold on; 
    plot(z, m, 'LineWidth', 2); 
    if exist('x','var') && exist('y','var')
        plot(x, y, '+', 'MarkerSize', 12)
    end;
    grid on
    xlabel('input, x')
    ylabel('output, y')
    axis tight;
