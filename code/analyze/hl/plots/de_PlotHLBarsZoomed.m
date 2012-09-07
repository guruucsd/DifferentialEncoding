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

  tidx = [mSets.data.LpSm   mSets.data.LmSp];

  fig = guru_newFig('ls-bars', 'bars', 1, length(tidx));
    
  % Legend
  if (length(mSets.sigma) == 2)
    lentries{1} = sprintf('RH net (\\sigma=%4.1f)',mSets.sigma(1));
    lentries{2} = sprintf('LH net (\\sigma=%4.1f)',mSets.sigma(2));
  else
    lentries   = guru_csprintf('\\sigma=%4.1f',num2cell(mSets.sigma));
  end;
  

  mfe_barweb(stats.basics.bars(tidx, :), ...
             stats.basics.bars_stde(tidx, :), ...
             0.6, ...
             strrep(mSets.data.TLBL(tidx),' ',sprintf('\n')),...
             [], [], [], [], [], lentries);
  hold on;
  
  % Crop y-axis 
  mx = max(max(stats.basics.bars(tidx, :)+stats.basics.bars_stde(tidx, :)));
  mn = min(min(stats.basics.bars(tidx, :)-stats.basics.bars_stde(tidx, :)));
  dff = mx-mn;
  
  set(gca,'ylim', [mn-dff/5, mx+2*dff/5]);
  if (false && length(mSets.sigma) == 2)
    mfe_xticklabels(1:2, {'Global', 'Local'});
    xlabel('Target Level');
  else
    mfe_xticklabels(1:length(tidx), strrep(mSets.data.TLBL(tidx),' ',sprintf('\n')));
    xlabel('Condition');
  end;
 
  ylabel('Error');
  title('Model Data');             
  box('on');