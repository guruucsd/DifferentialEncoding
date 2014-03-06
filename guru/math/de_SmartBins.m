function [bins, binWidth] = de_SmartBins(LS, w)
%
%

  if (~exist('w','var')), w = size(LS,2); end;

  rons = size(LS,1);
  binFactor = (rons/25);

  s = nan_sum(LS,2);
  m = nan_mean(s,1);
  d = nan_std(s,1);

  if (d==0)
      binWidth=1;
      bins = [LS(1) - 1, LS(1)];

  else

      binWidth = (d/binFactor);
      llim = [min(min(LS))]-eps;
      rlim = [max(max(LS))]+eps;
      bins     = [-inf llim:binWidth:rlim inf];
      if (isempty(bins))
        error('Invalid LS data');
      end;

  end;

