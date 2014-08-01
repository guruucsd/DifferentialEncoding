function sem = guru_sem(data, dim)
    if ~exist('dim','var')
        sem = std(data) ./ sqrt(length(data));
    else
        sem = std(data, [], dim) ./ sqrt(size(data, dim));
    end;