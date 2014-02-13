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

  fig = de_NewFig('ls-bars', 'bars', 1, length(tidx));
    
  % Legend
  if (length(mSets.sigma) == 2 && length(mSets.mu)==1)
    lentries{1} = sprintf('RH net (\\mu=%4.1f; \\sigma=%4.1f)', mSets.mu(1), mSets.sigma(1));
    lentries{2} = sprintf('LH net (\\mu=%4.1f; \\sigma=%4.1f)', mSets.mu(1), mSets.sigma(2));
  else
    for i=1:max(length(mSets.mu), length(mSets.sigma))
      if (length(mSets.mu)==1), mu = mSets.mu;
      else,                     mu = mSets.mu(i);
      end;
      if (length(mSets.sigma)==1), sig = mSets.sigma;
      else,                        sig = mSets.sigma(i);
      end;

      lentries{i} = sprintf('\\mu=%4.1f; \\sigma=%4.1f', mu, sig);
    end;
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
