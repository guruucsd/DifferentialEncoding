function figure1 = de_CreateSlotnickFigure1(Y1, E1, taskTitle, rons, ax)
% de_CreateSlotnickFigure1(Y1, E1)
%  Y1:  errorbar y
%  E1:  errorbar e
%  taskTitle: slotnick task (captialized first letter)

if ~exist('ax', 'var')
    % Create figure
    figure1 = de_NewFig(sprintf('blobdot_%s', lower(taskTitle)));
    ax = gca(); % make current figure the axis if not passed in.
end

% Create errorbar
errorbar(ax, Y1,E1,'MarkerSize', 15,...
		 'MarkerFaceColor', [0.600000023841858 0.200000002980232 0],...
		 'MarkerEdgeColor', [0.600000023841858 0.200000002980232 0],...
		 'Marker', 'square',...
		 'Color', [0 0 1]);
box(ax, 'on');

% Set the remaining axes properties
set(ax, 'XTick', [1 2], 'XTickLabel', {'LH', 'RH'});
ylabel(ax, 'Percent error');
title(ax, sprintf('%s Stimuli: Blob Dot (n=%d)', taskTitle, rons)); 


figure1.handle = gcf();

