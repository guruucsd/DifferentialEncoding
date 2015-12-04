function [fig] = de_PlotOutliers(mSets, LS, sigma, rin)
%function [fig] = de_PlotOutliers(LS, sigma, r)
%
% Rejects trials based on a given rejections algorithm
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
  tidx = [mSets.data.LpSm mSets.data.LmSp mSets.data.LpSp mSets.data.LmSm];
  tlbl = mSets.data.TLBL(tidx);

  fig = de_NewFig('outliers', 'bars', length(tidx), 10);

  % If there are no rejections, there's no more work to do.
  if (~exist('rin','var'))
    r=[];
  else
    r = zeros(size(rin,1),1);
    for i=1:size(rin,2)
      r = bitor(r,rin(:,i));
    end;
  end;


  % Calculate LS error
  ncols = 2;
  nrows = ceil(length(tidx)/ncols);

  for j=1:length(tidx)
    data = LS(:,tidx(j));
    runs = length(data);

    % Sometimes we have conditions without trials
    if (isempty(find(~isnan(data))))
      continue;
    end;

    % this code won't work if the data are totally homogenous
    if (std(data,1) ~= 0)
      [bins, binWidth] = de_SmartBins(data); %[0:(1/runs):max(data)];
      bins = [bins (bins(end)+binWidth):binWidth:max(data)];

      [a,b] = histc(data,bins);
      a = a/length(data);

      subplot(nrows,ncols,j);
      bar(bins,a);

      hold on;
      %set(gca, 'ylim',[0 0.06]);

      % plot any outlier as yellow.
      ylim = get(gca, 'ylim');
      if (~isempty(find(r)))
        plot(data(find(r))-binWidth/4, diff(ylim)/10, '*y');
      end;

      % plot any outlier that CAUSED this rejection as RED.
      ur = find(bitand(r, 2.^(tidx(j)-1)));
      if (~isempty(ur))
        plot(data(ur)-binWidth/4, 2*diff(ylim)/10, '*r');
      end;
      set(gca, 'Xlim', [bins(1)-binWidth/2 bins(end)+binWidth/2]);
    end;

    % Set properties
    xlabel( sprintf('%s: %d/%d rejections caused here.', tlbl{j}, length(ur), length(find(r))) );
  end;

  %legend('', ');
