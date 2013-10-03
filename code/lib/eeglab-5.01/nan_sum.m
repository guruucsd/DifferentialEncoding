function s = nan_sum(m,d)
  if (~exist('d','var'))
    if (prod(size(m)) == length(m))
      d = find(size(m)~=1);
    else
      d = 1;
    end;
  end;
  
  m(find(isnan(m))) = 0;
  s = sum(m, d);