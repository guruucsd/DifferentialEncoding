function figure1 = de_CreateSlotnickFigure1(Y1, E1, taskTitle, rons)
% de_CreateSlotnickFigure1(Y1, E1)
%  Y1:  errorbar y
%  E1:  errorbar e
%  taskTitle: slotnick task (captialized first letter)

% Create figure
figure1 = de_NewFig(sprintf('blobdot_%s', lower(taskTitle)));

% Create errorbar
errorbar(Y1,E1,'MarkerSize', 15,...
		 'MarkerFaceColor', [0.600000023841858 0.200000002980232 0],...
		 'MarkerEdgeColor', [0.600000023841858 0.200000002980232 0],...
		 'Marker', 'square',...
		 'Color', [0 0 1]);
box(gca(),'on');

% Set the remaining axes properties
set(gca(),'XTick', [1 2], 'XTickLabel', {'LH', 'RH'});
ylabel('Percent error');
title(sprintf('%s Stimuli: Blob Dot (n=%d)', taskTitle, rons)); 
