function m = guru_nan_mean(v)
  if (prod(size(v)) ~= length(v))
    for i=1:size(v,1)
      m(i,:) = guru_nan_mean(v(i,:));
    end;
  else
    m = mean(v(find(~isnan(v))));
  end;