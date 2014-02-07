function demo_interaction(figs)
    if ~exist('figs','var'), figs=[]; end;

    brainsz = 10.^(0:0.1:3);
    lat = sqrt(log(brainsz)); lat = 100*lat ./ max(lat);
    comm = exp(-0.5*log(brainsz)); comm = 100*comm ./ max(comm);

    % Figure 1: brain size vs. lateralization
    if (ismember(1, figs) || isempty(figs))
        figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, lat, 'b', 'LineWidth', 5);
        xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'ytick', []);  % yaxis unlabeled
        legend({'Lateralization'}, 'Location', 'NorthWest')    
    end;

    % Figure 2: brain size vs. interhemispheric communication
    if (ismember(2, figs) || isempty(figs))
        figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, comm, 'r', 'LineWidth', 5);
        xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'ytick', []);  % yaxis unlabeled
        legend({sprintf('Interhemispheric\ncommunication')}, 'Location', 'NorthWest')    
    end;
    
    % Figure 3: brain size vs. interhemispheric communication
    if (ismember(2, figs) || isempty(figs))
        figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, comm, 'r', 'LineWidth', 5);
        hold on;
        semilogx(brainsz, lat, 'b', 'LineWidth', 5);
        xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'ytick', []);  % yaxis unlabeled
        legend({sprintf('Interhemispheric\ncommunication'), 'Lateralization'}, 'Location', 'NorthWest')    
    end;
    
    