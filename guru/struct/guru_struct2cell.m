function cellarr = guru_struct2cell(obj)
%function cellarr = guru_struct2cell(obj)
%
% Returns a cell array that, if struct() is called on it, gives you 
%   the original struct passed in to the function.

    fields = fieldnames(obj);
    vals = struct2cell(obj);
    cellarr = [fields(:) vals(:)]';
    cellarr = cellarr(:)';
