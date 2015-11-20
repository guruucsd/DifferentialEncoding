function figure1 = de_CreateSlotnickFigure1(Y1, E1, taskTitle, rons, ax, yrng)
% de_CreateSlotnickFigure1(Y1, E1)
%  Y1:  errorbar y
%  E1:  errorbar e
%  taskTitle: slotnick task (captialized first letter)

if ~exist('ax', 'var')
    % Create figure
    figure1 = de_NewFig(sprintf('blobdot_%s', lower(taskTitle)));
    ax = gca();
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
if exist('yrng', 'var')
    avg = mean(Y1);
    minimum = avg - 2*yrng; % Only need yrng/2 for full range, but 2* yrng for room for error bar
    maximum = avg + 2*yrng;
    ylim([minimum, maximum])
end
ylabel(ax, 'Percent error');
title(ax, sprintf('%s Stimuli: Blob Dot (n=%d)', taskTitle, rons)); 


figure1.handle = gcf();

