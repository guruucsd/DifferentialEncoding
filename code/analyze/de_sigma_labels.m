function lbls = de_sigma_labels(mss)
%
  if (iscell(mss))
    model = mss{1}(1);
  else
    model = mss(1);
  end;

  if (length(model.sigma)==2)
    [sigmas,idx] = sort(model.sigma);
    lbls = { sprintf('RH (\\sigma=%3.1f)', sigmas(1)), ...
             sprintf('LH (\\sigma=%3.1f)', sigmas(2)) };
    lbls = lbls(idx);

  else
    lbls = guru_csprintf( '\\sigma=%3.1f', num2cell(model.sigma) );

  end;

