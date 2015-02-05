function [p,mn,var] = fitpdf(pdf, distn, bins, guess, showfig)
% function [p,mean,var] = fit_IUBD(distn, bins)
%
% distn : histogram
% bins : values of histogram bins (centers)
%
% p : distirbution parameters
% mn: mean of parameterized distribution
% var : variance of parameterized distribution

    if ~exist('guess','var'), guess = [0.1 0.1]; end;
    if ~exist('showfig','var'), showfig = true; end;
    
    distn = distn./sum(distn);
    
     % Fit a IUBD to the original aboitiz et al distribution

    dndist = @(d1,d2) (sum( (d1 - d2).^2 ));
    fitfn = @(data,x,pdf,p) (dndist(data,mean(diff(x))*pdf(x,p{:})));

    % Fitting functions
    [p] = fminsearch(@(p) fitfn(distn, bins, pdf, num2cell(p)), guess, optimset('MaxIter', 1000, 'Display', 'iter'));
    
    
    % Plot the result!
    %figure;
    if showfig
        bar(bins, distn);
        hold on;
        xvals = 0:0.01:max(bins); spacing_fact = 0.01*mean(diff(bins));
        pcell = num2cell(p);
        p1 = pdf(xvals, pcell{:})*mean(diff(bins));
        plot(xvals, p1, 'r--', 'LineWidth', 4);
        %set(gca, 'xlim', [0 0.8]);
        legend({'Original data', 'Curve [estimated]'}); 
        set(gca, 'FontSize', 14);
        title('Fitting using gradient descent', 'FontSize', 16);
        xlabel('axon diameter ( {\mu}m)', 'FontSize', 14);
        ylabel('proportion', 'FontSize', 14);
    end;
    
    
    %prod(p(1:2))
    mn = exp(p(1)+p(2).^2/2);
    var = (exp(p(2).^2)-1).*exp(2*p(1)+p(2).^2);
    
    
    
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
 