function [fig] = de_PlotHLBars(mSets, stats)
%function [h] = de_PlotHLBars(mSets, stats)
%
% Plot LpSm,LmSp,LpSp,LmSm
%
% Input:
%
% Output:
% h             : array of handles to plots

  tidx = [mSets.data.aux.idx.LpSpID mSets.data.aux.idx.LpSpNID ...
          mSets.data.aux.idx.LpSm   mSets.data.aux.idx.LmSp  ...
          mSets.data.aux.idx.LmSmID mSets.data.aux.idx.LmSmNID];

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
             strrep(mSets.data.aux.TLAB(tidx),' ',sprintf('\n')),...
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
