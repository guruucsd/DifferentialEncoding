function [arr,flds] = getfields(var, flds)

if ~exist('fields','var'), flds = fields(var); end;

arr = cell(size(flds));
for fi=1:numel(flds)
    arr{fi} = var.(flds{fi});
end;