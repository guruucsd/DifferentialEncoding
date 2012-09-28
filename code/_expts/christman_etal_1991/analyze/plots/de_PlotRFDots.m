function [fig] = de_PloRFDots(mSets, stats)
%function [h] = de_PloRFDots(modelSettings)
% Make a figure like figs 1 and 2
%
% Output:
% h             : array of handles to plots

  %keyboard
  fig = de_NewFig('rf-dots');
  return;
  
  tidx = [mSets.data.LpSpID mSets.data.LpSpNID ...
          mSets.data.LpSm   mSets.data.LmSp  ...
          mSets.data.LmSmID mSets.data.LmSmNID];

  fig = de_NewFig('ls-bars', 'bars', 1, length(tidx));
    
  % Legend
  if (length(mSets.sigma) == 2 && length(mSets.mu)==1)
    if (mSets.mu(1)==0)
      lentries{1} = sprintf('RH (\\sigma=%4.1f)', mSets.sigma(1));
      lentries{2} = sprintf('LH (\\sigma=%4.1f)', mSets.sigma(2));
    else
      lentries{1} = sprintf('RH (\\mu=%4.1f; \\sigma=%4.1f)', mSets.mu(1), mSets.sigma(1));
      lentries{2} = sprintf('LH (\\mu=%4.1f; \\sigma=%4.1f)', mSets.mu(1), mSets.sigma(2));
    end;
  else
    for i=1:max(length(mSets.mu), length(mSets.sigma))
      if (length(mSets.mu)==1), mu = mSets.mu;
      else,                     mu = mSets.mu(i);
      end;
      if (length(mSets.sigma)==1), sig = mSets.sigma;
      else,                        sig = mSets.sigma(i);
      end;

      if (mu==0.0)
        lentries{i} = sprintf('\\sigma=%4.1f',sig);
      else
        lentries{i} = sprintf('\\mu=%4.1f; \\sigma=%4.1f', mu, sig);
      end;
    end;
  end;
  
  mfe_barweb(stats.basics.bars(tidx, :), ...
             stats.basics.bars_stde(tidx, :), ...
             0.8, ...
             strrep(mSets.data.TLBL(tidx),' ',sprintf('\n')),...
             [], [], [], [], [], lentries);
  hold on;
  
  % Crop y-axis 
  mx = max(max(stats.basics.bars(tidx, :)+stats.basics.bars_stde(tidx, :)));
  mn = min(min(stats.basics.bars(tidx, :)-stats.basics.bars_stde(tidx, :)));
  dff = mx-mn;
  
  set(gca,'ylim', [mn-dff/5, mx+2*dff/5]);
  
  ylabel('Error');
  title('Model Data');             
  box('on');
  
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
