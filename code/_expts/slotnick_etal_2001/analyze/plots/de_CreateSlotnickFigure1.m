function figure1 = de_CreateSlotnickFigure1(Y1, E1, taskType, rons)
% de_CreateSlotnickFigure1(Y1, E1)
%  Y1:  errorbar y
%  E1:  errorbar e
%  taskType: slotnick task

% Create figure
figure1 = de_NewFig(sprintf('blobdot_%s', taskType));

% Create axes
axes1 = axes('Parent',figure1.handle, ...
    'Position',[0.128888888888889 0.11 0.775 0.815]);
hold(axes1,'on');

% Create errorbar
errorbar(Y1,E1,'MarkerSize',15,...
    'MarkerFaceColor',[0.600000023841858 0.200000002980232 0],...
    'MarkerEdgeColor',[0.600000023841858 0.200000002980232 0],...
    'Marker','square',...
    'Color',[0 0 1]);

box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XTick',[1 2],'XTickLabel',{'LH','RH'});

ylabel('Percent error');
title(sprintf('%s Stimuli: Blob Dot (n=%d)', taskType, rons)); 
