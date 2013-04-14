function [xi,x] = sample_discrete(p,sz,be,showplot)
% [xi,x] = sample_discrete(p,sz,be,showplot)
%
% p: probability mass function
% sz: size of output sample matrix
% be: bin edges (used if generating actual samples, not just discrete bins)
% showplot: true/false to show output plot
%
% xi: bins sampled from
% x: data (in ranges of be)
%
% returns BOTH sample as bin index, and samples as values between the bin
% edges

%if ~exist('sw','var'), sw = nan; end;
if ~exist('showplot','var'), showplot = false; end;

s = rand(sz);
pnorm = p(:)/sum(p);
p_be = [0;cumsum(pnorm);inf]; % bin edges
[c,xi] = histc(s(:),p_be);

if showplot
    figure; 
    subplot(1,2,1); bar(p, 1); hold on; title('original');
    subplot(1,2,2); bar(c/sum(c(:)), 'histc'); hold on; title('actual');
end;

if nargout==2
    if ~exist('be','var'), error('need bin edges to sample actual values!'); end;
    
    %diff(be([xi xi+1]),[],2);
    dbe = diff(be(1:2));
    x = be(xi)' + dbe.*(s(:)-p_be(xi))./pnorm(xi);
    
    x = reshape(x,sz);
    [c,xi] = histc(x(:),[be(1:end)]);

    if showplot
        figure; 
        subplot(1,2,1); set(gca, 'FontSize', 14);
        bar(be, p./sum(p(:)), 1);           hold on; 
        set(gca, 'xlim', be([1,end])); 
        title('original', 'FontSize', 16);
        
        subplot(1,2,2); set(gca, 'FontSize', 14);
        bar(be, c/sum(c(:)), 'histc'); hold on; 
        set(gca, 'xlim', be([1,end])); 
        title('actual', 'FontSize', 16);
    end;
end;

xi = reshape(xi,sz);
