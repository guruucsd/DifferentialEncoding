  %%
  [t1 t2] = meshgrid(-4:0.1:4,-4:0.1:4);
  t = [t1(:) t2(:)]; n = length(t);                 % these are the test inputs
  tmm = bsxfun(@minus, t, m1');
  p1 = n1*exp(-sum(tmm*inv(S1).*tmm/2,2))/sqrt(det(S1));
  tmm = bsxfun(@minus, t, m2');
  p2 = n2*exp(-sum(tmm*inv(S2).*tmm/2,2))/sqrt(det(S2));
  contour(t1, t2, reshape(p2./(p1+p2), size(t1)), [0.1:0.1:0.9]);

  
  %%
  meanfunc = @meanConst; hyp.mean = 0;
  covfunc = @covSEard; ell = 1.0; sf = 1.0; hyp.cov = log([ell ell sf]);
  likfunc = @likErf;

  hyp = minimize(hyp, @gp, -40, @infEP, meanfunc, covfunc, likfunc, x, y);
  [a b c d lp] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, x, y, t, ones(n, 1));

  plot(x1(1,:), x1(2,:), 'b+'); hold on; plot(x2(1,:), x2(2,:), 'r+')
  contour(t1, t2, reshape(exp(lp), size(t1)), [0.1:0.1:0.9]);
  
  
  %%
   meanfunc = @meanConst; hyp.mean = 0;
  covfunc = @covSEard; ell = 1.0; sf = 1.0; hyp.cov = log([ell ell sf]);
  likfunc = @likErf;

  hyp = minimize(hyp, @gp, -40, @infEP, meanfunc, covfunc, likfunc, x, y);
  [a b c d lp] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, x, y, t, ones(n, 1));

  plot(x1(1,:), x1(2,:), 'b+'); hold on; plot(x2(1,:), x2(2,:), 'r+')
  contour(t1, t2, reshape(exp(lp), size(t1)), [0.1:0.1:0.9]);
