function [p,fitidx,nofitidx] = fitpmf(pmf, distn, bins, guess, frac, showfig)
% function [p,mean,var] = fit_IUBD(distn, bins)
%
% distn : histogram
% bins : values of histogram bins (centers)
% guess : 
% frac: minimum height (fraction of max height); by default, use all
%     heights.
%
% p : distirbution parameters
% mn: mean of parameterized distribution
% var : variance of parameterized distribution

    if ~exist('guess','var'), guess = [0.1 0.1]; end;
    if ~exist('frac','var'),  frac  = 0; end;
    if ~exist('showfig','var'), showfig = false; end;
    
    distn = distn./sum(distn);
    
     % Fit a IUBD to the original aboitiz et al distribution
    
%    xidx = @(data,frac) (maxidx(data)+find(frac>data(maxidx(data)), 1, 'first'))
%    idx = @(data,frac) guru_iff(isempty(xidx(data,frac)), 1:numel(data), xidx(data,frac));
    goodidx = @(data, x, frac) (~isnan(data) & ~isinf(x) & data./max(data(:))>=frac);
    dndist = @(d1,d2,idx) sum( abs(d1(idx) - d2(idx)).^1 );
    fitfn = @(data,x,pmf,p) (dndist(data,pmf(x,p), min(find(goodidx(data,x,frac))):max(find(goodidx(data,x,frac)))));

    % Fitting functions
    [p] = fminsearch(@(p) fitfn(distn, bins, pmf, p), guess, optimset('MaxIter', 5000, 'Display', 'none'));
    fitidx   = min(find(goodidx(distn, bins, frac))):max(find(goodidx(distn,bins,frac)));
    nofitidx = setdiff(1:numel(distn), fitidx);

    % Plot the result!
    %figure;
    if showfig
        idx = 1:find(goodidx(distn, bins, frac), 1, 'last');
        fitpm = pmf(bins,p);
        
        bar(bins(idx), distn(idx));
        hold on;
        xvals = 0:0.01:max(bins(idx)); spacing_fact = mean(diff(bins(idx)))/0.01;
        p1 = pmf(xvals, p)*spacing_fact;
        plot(xvals, p1, 'r--', 'LineWidth', 3);
        plot(bins(fitidx),  fitpm(fitidx),   '*g', 'MarkerSize', 4, 'LineWidth', 2);
        plot(bins(nofitidx),fitpm(nofitidx), '*k', 'MarkerSize', 2, 'LineWidth', 2);
        legend({'Original data', 'Curve [estimated]'}); 
        set(gca, 'FontSize', 14);
        ylabel('proportion');
        title('Fitted using fminsearch', 'FontSize', 16);
    end;
    
    %prod(p(1:2))
    
    
function idx = maxidx(m,y,d)
  if exist('d','var'), [~,idx] = max(m,y,d); 
  elseif exist('y','var'), [~,idx] = max(m,y);
  else,                [~,idx] = max(x);
  end;
  
function err = meankldiv(xv, d1, d2)
  if abs(sum(d1)-1)>1E-10, err=inf; return; end;
  if abs(sum(d2)-1)>1E-10, err=inf; return; end;

  minval = min([1E-5, min(d1(d1>0)), min(d2(d2>0))]);
  d1x = d1; d1x(d1x==0)=minval; d1x = d1x./sum(d1x);
  d2x = d2; d2x(d2x==0)=minval; d2x = d2x./sum(d2x);
  
  e1 = kldiv(xv,d1x,d2x);
  e2 = kldiv(xv,d2x,d1x);
 
  if any(~isreal(e1)) || any(~isreal(e2))
      err = inf;
  else
      err = (e1+e2)/2;
  end;
 