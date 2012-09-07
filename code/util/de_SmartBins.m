function [bins, binWidth] = de_SmartBins(LS, w)
%
%

  if (~exist('w','var')), w = size(LS,2); end;
  
  rons = size(LS,1);
  binFactor = (rons/25);

  s = nan_sum(LS,2);
  m = nan_mean(s,1);
  d = nan_std(s,1);
  
  binWidth = (d/binFactor);
  llim = [min(min(LS))];
  rlim = [max(max(LS))] + binWidth;
  bins     = llim:binWidth:rlim;
  if (isempty(bins))
    error('Invalid LS data');
  end;
  
  