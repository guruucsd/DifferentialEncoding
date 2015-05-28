function abc = guru_num2cell(arr, dim)

if ~exist('dim', 'var')
    abc = num2cell(arr);
else
    try
        abc = num2cell(arr, dim);
    catch
        abc = cell(size(arr, dim), 1);
        arrdims = size(arr);
        newdims = [dim setdiff(1:length(size(arr)), dim)]
        for di=1:length(abc)
            arr2 = permute(arr, newdims);
            abc{di} = arr2(di, :);
        end;
    end;
end;
