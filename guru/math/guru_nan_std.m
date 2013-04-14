function m = guru_nan_std(v)
  if (prod(size(v)) ~= length(v))
    for i=1:size(v,1)
      m(i,:) = guru_nan_std(v(i,:));
    end;
  else
    m = std(v(find(~isnan(v))));
  end;