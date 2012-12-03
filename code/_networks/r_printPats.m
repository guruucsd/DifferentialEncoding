function r_printPats(data)
    
        fprintf('Patterns:\n');
        for i=1:data.npat
            fprintf('\t[[%2d %2d %2d %2d %2d] [%2d %2d %2d %2d %2d]] => [[%2d %2d %2d %2d %2d] [%2d %2d %2d %2d %2d]]\n', ...
                      data.P(1,i,2:end), data.d(1,i,1:end) );
        end;
    
