function figure1 = de_CreateSlotnickFigure1(Y1, E1, taskTitle, stimSet, lruns, rruns, ax)
% de_CreateSlotnickFigure1(Y1, E1)
%  Y1:  errorbar y
%  E1:  errorbar e
%  taskTitle: slotnick task (captialized first letter)
%  stimSet: e.g. categorical, coordinate
%  lruns: valid trials in LH; rruns = valid trials in RH
%  ax: the axis to plot to.

    if ~exist('ax', 'var')
        % Create figure
        figure1 = de_NewFig(sprintf('%s_%s', stimSet, lower(taskTitle)));
        ax = gca(); % make current figure the axis if not passed in.
    end

    % REVERSE the order of data, as Slotnick plots
    % the *hemisphere injected*, whereas our data are for
    % the hemisphere running.
    errorbar(ax, Y1(end:-1:1), E1(end:-1:1),'MarkerSize', 15,...
             'MarkerFaceColor', [0.600000023841858 0.200000002980232 0],...
             'MarkerEdgeColor', [0.600000023841858 0.200000002980232 0],...
             'Marker', 'square',...
             'Color', [0 0 1]);
    box(ax, 'on');

    % Set the remaining axes properties
    set(ax, 'XTick', [1 2], ...
            'XTickLabel', {sprintf('LH runs: %d', lruns), sprintf('RH runs: %d', rruns)});
    xlabel('Hemisphere Injected');  % weird, right??
    ylabel(ax, 'Sum squared error');
    title(ax, sprintf('%s\n%s\n ', taskTitle, stimSet));
    
    yrule = ax.YAxis;
    yrule.FontSize=15

