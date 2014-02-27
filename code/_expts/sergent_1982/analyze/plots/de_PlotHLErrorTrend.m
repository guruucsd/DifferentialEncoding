function [fig] = de_PlotErrorTrend(mSets, LS, sigmas, r)
%[fig] = de_PlotErrorTrend(mSets, LS, sigmas, r)
%
% Plots error as a function of time/run
%
% Input:
% LS     :
% sigmas :
% r      : indices of rejected
%
% Output:
% fig      : array of handles to plots

  global colors;
  colors = {'r', 'g', 'k', 'y', 'k', 'b'};

  if (~exist('rmodes','var')), rmodes = {}; end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Show trend of encoding error, according to type (Reza's plots)
  %   This plot will show outliers as spikes.
  %   Create old-style info

  fig.name   = 'error-trend';
  fig.handle = figure;

  tidx = [mSets.data.LpSm mSets.data.LmSp mSets.data.LpSp mSets.data.LmSm];
  for i=1:length(tidx)
    subplot(2,2,i);
    de_PlotRezaErrorTrend(LS, i, sigmas);

    % show rejections
    if (exist('r','var'))
      for j=1:length(sigmas)
        plot(r{j},LS{j}(r{j},i), ['*' colors{j}]);
      end;
    end;
  end;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotRezaErrorTrend(LS, idx, sigmas)
    global colors;

    hold on;

    % Plot the trend for each sigma
    xlim = [1 1];
    for i=1:length(LS)
      plot(LS{i}(:,idx), colors{i});
      xlim(2) = max(xlim(2), length(LS{i}(:,idx)));
    end;

    set(gca,'xlim',xlim);
    legend( guru_csprintf('o=%4.1f', num2cell(sigmas)) );
    title(sprintf('Error trend w/ rejections for ?'));
