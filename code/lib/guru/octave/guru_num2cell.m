function cellarr = guru_num2cell(arr, dim)

if ~exist('dim', 'var')
    cellarr = num2cell(arr);
else
    try
        cellarr = num2cell(arr, dim);
    catch
        cellarr = cell(size(arr, dim), 1);
        arrdims = size(arr);
        newdims = [dim setdiff(1:length(size(arr)), dim)]
        for di=1:length(cellarr)
            arr2 = permute(arr, newdims);
            cellarr{di} = arr2(di, :);
        end;
    end;
end;
