function [fig] = de_PlotHLBars(mSets, stats)
%function [h] = de_PlotHLBars(modelSettings)
%
% Plot LpSm,LmSp,LpSp,LmSm
%
% Input:
% LS            :
% sigmas    :
% errorType         : (optional) rejections mode

% Output:
% h             : array of handles to plots

  tidx = [mSets.data.LpSpID mSets.data.LpSpNID ...
          mSets.data.LpSm   mSets.data.LmSp  ...
          mSets.data.LmSmID mSets.data.LmSmNID];

  fig = guru_newFig('ls-bars', 'bars', 1, length(tidx));
    
  % Legend
  if (length(mSets.sigma) == 2)
    lentries{1} = sprintf('LVF/RH net (\\sigma=%4.1f)',mSets.sigma(1));
    lentries{2} = sprintf('RVF/LH net (\\sigma=%4.1f)',mSets.sigma(2));
  else
    lentries   = guru_csprintf('\\sigma=%4.1f',num2cell(mSets.sigma));
  end;
  

  mfe_barweb(stats.basics.bars(tidx, :), ...
             stats.basics.bars_stde(tidx, :), ...
             0.8, ...
             strrep(mSets.data.TLBL(tidx),' ',sprintf('\n')),...
             [], [], [], [], [], lentries);

%  else
%    bar(err(tidx, :));
%    set(gca,'tickdir','out');
%    mfe_xticklabels(gca,1:length(tidx),strrep(mSets.data.TLBL(tidx),' ',sprintf('\n')));
%    
%    if (length(mSets.sigma)==2)
%      legend(lentries, 'Location','NorthWest');
%    elseif (length(lentries)<3)
%      legend(lentries,'Location','NorthOutside');
%    else
%      legend(lentries,'Location','EastOutside');
%    end;
%  end;
