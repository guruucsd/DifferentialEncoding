function negsemilogy(x, y, varargin)
% Two cases:
%   1. -1 < y < 1:
%      then log10(abs(y)) < 0 for all cases.  Flip the sign of log10(abs(y)),
%      then plot all data.
%   2. -inf < y < inf
%      then simply discard all values for which log10(abs(y)) < 0 (can't be visualized).

    % The 'cutoff' variable determines at what value results are clipped.
    %  Default is 1.
    if ~exist('cutoff', 'var'), cutoff = 0.01; end;

    plot_comparison_idx = cellfun(@(c) ischar(c) && strcmp(c, 'plot_comparison'), varargin);
    if any(plot_comparison_idx)
        varargin = varargin(~plot_comparison_idx); % strip 'plot_comparison' arg

        % Create a new figure with two subplots; show
        %   the non-semilog version on the left,
        %   and prep the right side for showing
        %   the semilog version.
        figure;
        subplot(1, 2, 1);
        plot(x, y, varargin{:});
        hold on;
        plot(x, -cutoff * ones(size(x)), 'r--');
        plot(x, cutoff * ones(size(x)), 'r--');
        subplot(1, 2, 2);
    end;

    y = y / cutoff;  % normalize things, work with values at/below 1.  Deal with things through labels.
    posy_idx      = y >= 0;
    posy_gte1_idx = posy_idx & y >= 1;   % log10(abs(y)) >= 0
    posy_lt1_idx  = posy_idx & y < 1;    % log10(abs(y)) < 0

    negy_idx       = y < 0;
    negy_ltem1_idx = negy_idx & y <= -1; % log10(abs(y)) >= 0
    negy_gte1_idx  = negy_idx & y > -1;  % log10(abs(y)) < 0


    if isempty(negy_idx) || isempty(posy_idx)
        fprintf('Classic case; use semilogy!');
        semilogy(x, y, varargin{:});

    elseif isempty(negy_ltem1_idx) && isempty(posy_gte1_idx)
        fprintf('First case.\n');
        safey = y;
        safey(posy_gte1_idx) = 1;
        safey(negy_ltem1_idx) = 1;
        signy = sign(safey);
        logabsy = log10(abs(safey));
        ploty = -signy .* logabsy;
        plot(x, ploty, varargin{:});

    else
        fprintf('Second case.\n');
        safey = y;
        safey(posy_lt1_idx) = 1;
        safey(negy_gte1_idx) = 1;
        signy = sign(safey);
        logabsy = log10(abs(safey));
        ploty = signy .* logabsy;
        plot(x, ploty, varargin{:});
        hold on;
        plot(x(posy_lt1_idx), zeros(size(x(posy_lt1_idx))), 'xr');
        plot(x(negy_gte1_idx), zeros(size(x(negy_gte1_idx))), 'xr');

        log_yticks = get(gca, 'ytick')
        nonlog_yticks = sign(log_yticks) .* 10.^abs(log_yticks);
        ylabels = arrayfun(@(yt) sprintf('%d^{%d}', sign(yt)*10, abs(yt) + log10(cutoff)), log_yticks, 'UniformOutput', false);
        ylabels{log_yticks == 0} = 'Undefined';
        yticklabels(ylabels, 'FontSize', get(gca, 'FontSize'));

        xticklabels(get(gca, 'xticklabel'), 'FontSize', get(gca, 'FontSize'));
    end;



function yticklabels(labels, varargin)
% Taken from http://www.mathworks.com/matlabcentral/answers/102053-how-can-i-make-the-xtick-and-ytick-labels-of-my-axes-utilize-the-latex-fonts-in-matlab-8-1-r2013a

    if ~iscell(labels)
        labels = arrayfun(@(n) num2str(n), labels, 'UniformOutput', false);
    end;

    set(gca,'yticklabel',[]);  %Remove tick labels

    %% Get tick mark positions
    yTicks = get(gca,'ytick');
    HorizontalOffset = 0.1;

    ax_pos = axis; %Get left most x-position

    %% Reset the ytick labels in desired font
    for i = 1:length(yTicks)
    %Create text box and set appropriate properties
         text(ax_pos(1) - HorizontalOffset, yTicks(i), ['$' labels{i} '$'], ...%labels(i),...
             'HorizontalAlignment','Right','interpreter', 'latex', varargin{:});
    end



function xticklabels(labels, varargin)
% Taken from http://www.mathworks.com/matlabcentral/answers/102053-how-can-i-make-the-xtick-and-ytick-labels-of-my-axes-utilize-the-latex-fonts-in-matlab-8-1-r2013a
    if ~iscell(labels)
        labels = arrayfun(@(n) num2str(n), labels, 'UniformOutput', false);
    end;

    set(gca,'xticklabel',[]);  %Remove tick labels

    %% Get tick mark positions
    xTicks = get(gca, 'xtick');
    yTicks = get(gca,'ytick');
    HorizontalOffset = 0.1;

    ax_pos = axis; %Get left most x-position

    %% Reset the xtick labels in desired font
    minY = min(yTicks);
    verticalOffset = 0.2;
    for xx = 1:length(xTicks)
    %Create text box and set appropriate properties
         text(xTicks(xx), minY - verticalOffset, ['$' labels{xx} '$'],...
             'HorizontalAlignment','Right','interpreter', 'latex', varargin{:});
    end;
