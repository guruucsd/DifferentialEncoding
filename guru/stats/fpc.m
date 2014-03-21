function [C,p] = fpc(X)
%function [C,p] = fpc(X)
% full partial correlation
%
% X: rows are measurements, columns are variables
%
% C: correlation between variables i,j with all other variables partialed out.
% p: significance value

nvars = size(X,2);
C = eye(nvars);
p = zeros(size(C));

for ci=1:nvars
    for ri=ci+1:nvars
        [a,b] = partialcorr(X(:,[ci,ri]), X(:,setdiff(1:nvars,[ci,ri])));
        C(ri,ci) = a(2); C(ci,ri) = a(2);
        p(ri,ci) = b(2); p(ci,ri) = b(2);
    end;
end;
