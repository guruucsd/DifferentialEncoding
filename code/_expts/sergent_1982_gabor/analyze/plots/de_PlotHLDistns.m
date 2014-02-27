function [fig] = de_PlotLSDistns(mSets, LS, sigma)
%function [fig] = de_PlotLSDistns(LS, sigma)
%
% Plot histogram for each set of LS results
%
% Input:
% model         : see de_model for details
% LS            :
% errAutoEnc    :
% rmode         : (optional) rejections mode
% dbg           : (optional)
%
% Output:
% fig             : array of handles to plots

  fig = de_NewFig('ls-distns', 'bars', 4, 10);

  tidx = [];
  for i=[mSets.data.LpSm mSets.data.LmSp mSets.data.LpSp mSets.data.LmSm]
    if (~isempty(find(~isnan(LS(:,i)))))
      tidx = [tidx i];
    end;
  end;


  ncols = 2;
  nrows = ceil(length(tidx)/ncols);

  for j=1:length(tidx)
    subplot(nrows,ncols,j);

    % Only works if data aren't homogenous
    if (std(LS(:,tidx(j)), 1)~=0)
      [bins,binWidth]  = de_SmartBins(LS(:,tidx(j)));
      [a,b] = histc(LS(:,tidx(j)),bins);
      a = a/size(LS,1);

      bar(bins,a);
      hold on;

      set(gca, 'Xlim', [bins(1)-binWidth/2 bins(end)+binWidth/2]);
      %set(gca, 'xlim', [0 bins(end)+(bins(end)-bins(end-1))/2]);
    end;

    title(sprintf('%s: Err dist''n, o=%4.1f', mSets.data.TLBL{tidx(j)}, sigma));
  end;
