function p = r_randperm(n,m)
%R_RANDPERM Random permutation.
%   R_RANDPERM(n) is a random permutation of the integers from 1 to n.
%   For example, R_RANDPERM(6) might be [2 4 5 6 1 3].
%   
%   R_RANDPERM(n,m) returns the first m results
%   Note that R_RANDPERM calls RAND and therefore changes RAND's state.
%
%   See also PERMUTE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:25:47 $
%   $Revision: 1.1.6.3 $  $Date: 2011/10/21 06:46:00 $

[~,p] = sort(rand(1,n));
if (exist('m','var'))
    p = p(1:m);
end;
