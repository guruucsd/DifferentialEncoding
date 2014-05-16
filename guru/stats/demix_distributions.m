function [pq] = demix_distributions(X,Y, m_unmy, m_myel)

    
    % Fit a lognormal to the original aboitiz et al distribution
    lognpdensf = @(x,mu,sigma) (diff([0 gamcdf([x(1:end-1) inf], mu, sigma)]));
    
    lognfitfn  = @(xbar, ybar, params) ( meankldiv(1:length(ybar), lognpdensf(xbar, params(1), params(2)),  ybar+eps) );
    
    kl_cost_fn = @(d,b,p,q) ( 1/(q>=0&q<=1).*meankldiv(b, (q*lognpdensf(b,p(1),p(2))+(1-q)*lognpdensf(b,p(3),p(4))), d) ); %d=distn, b=bins,p=params
    
    mean_cost_fn = @(mns,p) ( 1000*abs(p(1)*p(2)-mns(2)) + 1000*abs(p(3)*p(4)-mns(2)) );
    
    if ~exist('m_unmy','var'), m_unmy = nan; end;
    if ~exist('m_myel','var'), m_myel = nan; end;
    
    if isnan(m_myel) || isnan(m_unmy)
%        p = [-2 .5 -1 .75];
        p = [5 .1 4 .1];
        q = [0.5];
        % alternate between optimizing p and q
        for ii=1:10
            [p] = fminsearch(@(tp)( kl_cost_fn(Y, X, tp, q)), p, optimset('MaxIter', 100, 'Display', 'none'));
            [q] = fminsearch(@(tq)( kl_cost_fn(Y, X, p, tq)), q, optimset('MaxIter', 10, 'Display', 'none'));
        end;
        
    else
        [p] = fminsearch(@(p)(mean_cost_fn([m_unmy,m_myel],p) + kl_cost_fn(Y, X, p)), [0 m_unmy 0 m_myel]);
    end;
    
    
    % Plot the result!
    %figure;
    bar(X, Y);
    hold on;
    xvals = 0:0.01:2.5; spacing_fact = mean(diff(X))/0.01;
    p1 = lognpdensf(xvals, p(1), p(2))*spacing_fact*q;
    p2 = lognpdensf(xvals, p(3), p(4))*spacing_fact*(1-q);
    plot(xvals, p1, 'r', 'LineWidth', 4);
    plot(xvals, p2, 'g', 'LineWidth', 4);
    plot(xvals, p1+p2, 'k--', 'LineWidth', 4);
    %set(gca, 'xlim', [0 0.8]);
    legend({'Original data (Lamantia & Rakic, 1990b)', 'Unmyelinated [estimated]','Myelinated [estimated]', 'Total [estimated]'}); 
    set(gca, 'FontSize', 14);
    title('Demixing using gradient descent', 'FontSize', 16);
    xlabel('axon diameter ( {\mu}m)', 'FontSize', 14);
    ylabel('proportion', 'FontSize', 14);

    pq = [p q (1-q)];
    
    prod(p(1:2))
    prod(p(3:4))
    %exp(p(1)+p(2).^2)
    %exp(p(3)+p(4).^2)
    
function err = meankldiv(xv, d1, d2)
  if abs(sum(d1)-1)>1E-10, err=inf; return; end;
  if abs(sum(d2)-1)>1E-10, err=inf; return; end;

  e1 = kldiv(xv,d1+eps,d2+eps);
  e2 = kldiv(xv,d2+eps,d1+eps);
 
  if any(~isreal(e1)) || any(~isreal(e2))
      err = inf;
  else
      err = (e1+e2)/2;
  end;
 