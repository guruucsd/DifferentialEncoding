function [fig] = de_PlotHLBarsDivided(mSets, stats)
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

  fig = de_NewFig('ls-bars-div', 'bars', 2, length(tidx)*4);

  if (length(mSets.sigma==2))
    [nRows,nCols] = deal(1,2);
  else
    [nRows,nCols] = deguru_optSubplots(length(LS));
  end;

  yl = [0 max(max(stats.basics.bars+stats.basics.bars_stde))*1.05];
  
  [junk,sigorder] = sort(mSets.sigma, 2, 'ascend');
  if (length(mSets.sigma)==2)
    sigmaLabs = {'LVF/RH','RVF/LH'};
  else
    sigmaLabs = guru_csprintf('o=%3.1f', num2cell(mSets.sigma));
  end;
  
  for i=1:size(stats.basics.bars,2) %loop over sigma
    ss = sigorder(i);
    
    subplot(nRows,nCols,i);
    
    % Get stats
    ls_mean = stats.basics.bars(tidx, ss);
    ls_stde = stats.basics.bars_stde(tidx,ss);
    
    % Sort stats
    [d,idx] = sort(ls_mean);
    e = ls_stde(idx);
    %d = [d zeros(size(d))]
    %e = [e zeros(size(e))]
    
    lbls = strrep(mSets.data.TLBL(idx),' ',sprintf('\n'));
    %if (exist('errbars','var'))
    mfe_barweb(d, e, 0.8, lbls);
    set(gca, 'ylim', yl);
    
%    set(gca,'tickdir','out');
    title(sprintf('Sorted error for %s', sigmaLabs{ss}));
  end;
