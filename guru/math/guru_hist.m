function [c,xi] = guru_hist(x,be)

    [c,xi] = histc(x(:),[-inf; be(:); inf]);
    
    c = [c(1:end-3)' sum(c(end-2:end))]; % nothing will ever be between be(end) and inf
