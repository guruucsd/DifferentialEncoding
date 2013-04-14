function l = mfe_split(d,s,max)
%L=SPLIT(D,S) splits a string S delimited by characters in D.  Meant to
%             work roughly like the PERL split function (but without any
%             regular expression support).  Internally uses STRTOK to do 
%             the splitting.  Returns a cell array of strings.
%
%Example:
%    >> split('_/', 'this_is___a_/_string/_//')
%    ans = 
%        'this'    'is'    'a'    'string'   []
%
%Written by Gerald Dalley (dalleyg@mit.edu), 2004
if (~exist('max','var')), max = Inf; end;
if (iscell(s))
    l = cell(size(s));
    for i=1:numel(s)
        l{i} = mfe_split(d,s{i},max);
    end;
elseif (ischar(s))
    l = {};
    while (length(s) > 0 && length(l)<max)
        [t,s] = strtok(s,d);
        l = {l{:}, t};
    end
end;